  function openSidebar() {
    document.getElementById("sidebar").style.width = "250px";
  }

  function closeSidebar() {
    document.getElementById("sidebar").style.width = "0";
  }
  
  function playAudio(id) {
    const audio = document.getElementById(`audio-${id}`);
    audio.play();
  }