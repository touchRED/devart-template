// Generated by CoffeeScript 1.6.3
var animate, onRatio, onUserIn, onUserOut, renderer, setup, skeleton, stage, sync, windowResized;

stage = null;

renderer = null;

skeleton = null;

sync = null;

setup = function() {
  stage = new PIXI.Stage(0xFFFFFF);
  renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight);
  document.body.appendChild(renderer.view);
  skeleton = new Skeleton();
  stage.addChild(skeleton.view);
  sync = new SkeletonSync(skeleton);
  sync.onUserIn = onUserIn;
  sync.onUserOut = onUserOut;
  sync.onRatio = onRatio;
  windowResized();
  window.addEventListener('resize', windowResized);
  return requestAnimFrame(animate);
};

onRatio = function(ratio) {
  skeleton.dataRatio = ratio;
  return skeleton.resize();
};

onUserIn = function(userId) {
  return console.log("user " + userId + " entered");
};

onUserOut = function(userId) {
  return console.log("user " + userId + " exited");
};

windowResized = function(ev) {
  var sh, sw;
  sw = window.innerWidth * window.devicePixelRatio;
  sh = window.innerHeight * window.devicePixelRatio;
  renderer.resize(sw, sh);
  renderer.view.style.width = window.innerWidth + 'px';
  renderer.view.style.height = window.innerHeight + 'px';
  if (skeleton) {
    skeleton.resize();
    skeleton.view.position.x = sw * 0.5;
    return skeleton.view.position.y = sh * 0.5;
  }
};

animate = function() {
  requestAnimFrame(animate);
  skeleton.update();
  return renderer.render(stage);
};

setup();
