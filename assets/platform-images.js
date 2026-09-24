window.ZENTRA_IMAGES = Object.freeze({
  "netflix": "assets/platforms/netflix.png",
  "crunchyroll": "assets/platforms/crunchyroll.png",
  "spotify": "assets/platforms/spotify.png",
  "hbo max": "assets/platforms/hbo-max.png",
  "prime video": "assets/platforms/prime-video.png",
  "paramount+": "assets/platforms/paramount.png",
  "disney premium + espn": "assets/platforms/disney-espn.png",
  "disney premium sin espn": "assets/platforms/disney.png",
  "vix": "assets/platforms/vix.png",
  "canva pro": "assets/platforms/canva.png",
  "iptv": "assets/platforms/iptv.png",
  "youtube premium": "assets/platforms/youtube.png",
  "chatgpt plus": "assets/platforms/chatgpt.png",
  "apple tv+": "assets/platforms/apple-tv.png",
  "duolingo": "assets/platforms/duolingo.png",
  "gemini pro": "assets/platforms/gemini.png",
  "capcut pro": "assets/platforms/capcut.png"
});
window.zentraProductImage = function(product) {
  const custom = String(product?.image_url || "").trim();
  return custom || window.ZENTRA_IMAGES[String(product?.name || "").trim().toLowerCase()] || "assets/logo.png";
};
