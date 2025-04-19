require "bundler/setup"
Bundler.require
require "sinatra/reloader" if development?
require "./models.rb"
require 'fileutils'
require 'time'


use Rack::Session::Cookie, key: 'rack.session',
                           path: '/',
                           secret: ENV['SESSION_SECRET'] || 'super_secret_key',
                           expire_after: 2592000

helpers do
    def logged_in?
        !session[:user_id].nil?
    end
end

before do
    @isLoggedIn = logged_in?
end

get '/' do
      if !logged_in?
    redirect '/signin'
  else
    begin
      @user = User.find(session[:user_id])
    rescue ActiveRecord::RecordNotFound
      session.clear
      redirect '/signin'
    end
    @posts = Post.order(like_num: :desc)
    erb :index
  end
    @is_from_posts = false
    @user = User.find(session[:user_id])
    @posts = Post.order(like_num: :desc)
    #@posts = Post.where.not(user_id: @user.id).order(like_num: :desc)
    @liked_post_id_array = @user.int_array || []
    puts "liked post id array is #{@liked_post_id_array}"
    @posts.each do |post|
        puts "Post #{post.id} has #{post.like_num} likes"
    end


    erb :index
end

get '/signin' do
    erb :signin
end

get '/signup' do
    erb :signup
end

post '/signup' do
    user = User.create(username: params[:username], password: params[:password], int_array: [])
    if user.persisted?
        session[:user_id] = user.id
        redirect '/'
        return
    end
    redirect '/signup'
end

post '/signin' do
    user = User.find_by(username: params[:username])
    if user.nil?
        redirect 'signup'
        return
    end

    if !user.authenticate(params[:password])
        redirect 'signin'
        return
    end
    
    session[:user_id] = user.id
    redirect '/'
end

get '/upload' do
  erb :upload
end

post '/upload' do
  if not params[:mp3_file]
    return
  end
  
    original_filename = params[:mp3_file][:filename]
    file = params[:mp3_file][:tempfile]

    timestamp = Time.now.strftime('%Y%m%d%H%M%S')

    ext = File.extname(original_filename)
    base = File.basename(original_filename, ext)

    safe_base = base.gsub(/[^\w\-]/, '_')
    new_filename = "#{safe_base}_#{timestamp}#{ext}"

    save_path = "./public/uploads/#{new_filename}"
    FileUtils.mkdir_p('./public/uploads')

    # File.open(save_path, 'wb') do |f|
    #   f.write(file.read)
    # end
    
    file.rewind  # 💡 Ensure pointer is at the beginning
    file_contents = file.read



    puts "File uploaded successfully as #{new_filename}"
    
    db_file_path = "/uploads/#{new_filename}"
    
    post = Post.new(
  post_title: params[:post_title],
  description: params[:description],
  file_data: file_contents,
  like_num: 0,
  user_id: session[:user_id]
)

if post.save
  puts "✅ Post saved: #{post.inspect}"
else
  puts "❌ Failed to save post: #{post.errors.full_messages}"
end


    redirect '/'
    
end

get '/posts/:id/audio' do
  post = Post.find_by(id: params[:id])

  halt 404, "Post not found" if post.nil?
  halt 404, "No audio file found" if post.file_data.nil?

  data = post.file_data
  content_type 'audio/mpeg'
  headers['Content-Length'] = data.bytesize.to_s
  data
end


patch '/:id/download' do
    if !logged_in?
        redirect '/signin'
        return
    end

    upload = Post.find(params[:id])
    Download.create(file_path: upload.file_path, user_id: session[:user_id], uploads_id: params[:id], title: upload.post_title)
    redirect '/profile'
end

get '/profile' do
    if !logged_in?
        redirect '/signin'
        return
    end
    @user = User.find(session[:user_id])
    @downloaded_soundeffects = Download.where(user_id: session[:user_id])
    erb :profile
end

patch '/:id/change' do
    download = Download.find(params[:id])
    download.update(title: params[:title])
    redirect 'profile'
end

delete '/:id/delete' do
    download = Download.find(params[:id])
    download.destroy
    redirect '/profile'
end

delete '/:id/delete/post' do
    upload = Post.find(params[:id])
    download = Download.where(uploads_id: params[:id])
    download.destroy_all
    upload.destroy
    redirect '/'
end

patch '/:id/like' do
    if !logged_in?
        redirect '/signin'
        return
    end
  user = User.find(session[:user_id])
  upload = Post.find(params[:id])

  like_number = upload.like_num + 1
  upload.update(like_num: like_number)

  post_array = user.int_array || []
  post_id = params[:id].to_i
  post_array << post_id unless post_array.include?(post_id)

  if user.update_column(:int_array, post_array)
    puts "new post array is #{post_array}"
  else
    puts "Failed to update user: #{user.errors.full_messages}"
  end

  redirect '/'
end

patch '/:id/dislike' do
    if !logged_in?
        redirect '/signin'
        return
    end
    user = User.find(session[:user_id])
    upload = Post.find(params[:id])

    like_number = upload.like_num - 1
    upload.update(like_num: like_number)
    
    post_array = user.int_array || []
    post_id = params[:id].to_i
    post_array.delete(post_id)
    user.update_column(:int_array, post_array)
    redirect '/'
end

get '/search' do
  if !logged_in?
    redirect '/signin'
    return
  end

@is_from_posts = false
    
  @user = User.find(session[:user_id])
  @liked_post_id_array = @user.int_array
  @query = params[:query]

  @posts = Post.where("post_title LIKE ?", "%#{@query}%").order(like_num: :desc)

  erb :index
end


# get '/sound-deck' do
#     @user = User.find(session[:user_id])
#     erb :sounddeck
# end

get '/search-profile' do
    if !logged_in?
        redirect '/signin'
        return
    end
    @user = User.find(session[:user_id])
    @query = params[:query]
    @downloaded_soundeffects = Download.where(user_id: session[:user_id]).where("title LIKE ?", "%#{@query}%")
    erb :profile
end

get '/posts' do
    if !logged_in?
        redirect '/signin'
        return
    end
    @user = User.find(session[:user_id])
    @posts = Post.where(user_id: session[:user_id]).order(like_num: :desc)
    #@posts = Post.where.not(user_id: @user.id).order(like_num: :desc)
    @liked_post_id_array = @user.int_array
    @is_from_posts = true
    
    
    erb :index
end