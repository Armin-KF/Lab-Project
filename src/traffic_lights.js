// import * as THREE from 'three';
// import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';

// Initialize scene, camera, and renderer
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x333333);
const camera = new THREE.PerspectiveCamera(
  75,
  window.innerWidth / window.innerHeight,
  0.1,
  1000
);
const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// Orbit Controls for interactive camera movement
let controls;
try {
  controls = new THREE.OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;
} catch (e) {
  console.warn("OrbitControls not found. Skipping camera controls.");
}

// Adjust camera settings
camera.position.set(0, 2, 5);
if (controls) controls.target.set(0, 0, 0);

// Handle window resizing
window.addEventListener("resize", () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
});

// Add ambient and directional light
const ambientLight = new THREE.AmbientLight(0x404040, 1.5);
scene.add(ambientLight);
const directionalLight = new THREE.DirectionalLight(0xffffff, 0.5);
directionalLight.position.set(5, 10, 7.5).normalize();
scene.add(directionalLight);

// Light colors
const colors = {
  green: 0x00ff00,
  yellow: 0xffff00,
  red: 0xff0000,
  off: 0x333333,
};

// Create traffic light with housing and pole
function createTrafficLight(x, y, z) {
  const group = new THREE.Group();

  // Create lights
  const greenLight = new THREE.Mesh(
    new THREE.SphereGeometry(0.2),
    new THREE.MeshStandardMaterial({ color: colors.off })
  );
  greenLight.position.set(0, 0.5, 0);
  const yellowLight = new THREE.Mesh(
    new THREE.SphereGeometry(0.2),
    new THREE.MeshStandardMaterial({ color: colors.off })
  );
  yellowLight.position.set(0, 0, 0);
  const redLight = new THREE.Mesh(
    new THREE.SphereGeometry(0.2),
    new THREE.MeshStandardMaterial({ color: colors.off })
  );
  redLight.position.set(0, -0.5, 0);

  group.add(greenLight, yellowLight, redLight);

  // Housing and pole
  const housing = new THREE.Mesh(
    new THREE.BoxGeometry(0.5, 1.5, 0.5),
    new THREE.MeshStandardMaterial({ color: 0x222222 })
  );
  housing.position.set(0, 0, -0.3);
  const pole = new THREE.Mesh(
    new THREE.CylinderGeometry(0.1, 0.1, 3),
    new THREE.MeshStandardMaterial({ color: 0x333333 })
  );
  pole.position.set(0, -2, -0.3);
  group.add(housing, pole);

  group.position.set(x, y, z);
  scene.add(group);

  return { greenLight, yellowLight, redLight };
}

// Initialize two traffic lights
const LA = createTrafficLight(-1, 0, 0);
const LB = createTrafficLight(1, 0, 0);

// UI overlay for state information
const overlay = document.createElement("div");
overlay.style.position = "fixed";
overlay.style.top = "320px";
overlay.style.left = "590px";
overlay.style.padding = "10px 15px";
overlay.style.backgroundColor = "rgba(50, 50, 50, 0.8)";
overlay.style.color = "white";
overlay.style.fontSize = "16px";
overlay.style.fontFamily = "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";
overlay.style.borderRadius = "8px";
overlay.style.boxShadow = "0 4px 12px rgba(0, 0, 0, 0.4)";
overlay.style.zIndex = "1000";
overlay.style.transition = "all 0.3s ease";
document.body.appendChild(overlay);

// State machine variables
let state = 0;
const yellowDuration = 1.5;
const greenDuration = 2.5;
const clock = new THREE.Clock();
let elapsed = 0;

// Function to update traffic lights and overlay text
function updateTrafficLights() {
  // Turn all lights "off" initially
  LA.greenLight.material.color.set(colors.off);
  LA.yellowLight.material.color.set(colors.off);
  LA.redLight.material.color.set(colors.off);
  LB.greenLight.material.color.set(colors.off);
  LB.yellowLight.material.color.set(colors.off);
  LB.redLight.material.color.set(colors.off);

  let overlayText = "";

  switch (state) {
    case 0: // Academic Ave: Green, Bravado Blvd: Red
      LA.greenLight.material.color.set(colors.green);
      LB.redLight.material.color.set(colors.red);
      overlayText = `Academic Ave: Green (${Math.max(
        0,
        greenDuration - elapsed
      ).toFixed(1)}s)`;
      if (elapsed > greenDuration) {
        state = 1;
        elapsed = 0;
      }
      break;

    case 1: // Academic Ave: Yellow, Bravado Blvd: Red
      LA.yellowLight.material.color.set(colors.yellow);
      LB.redLight.material.color.set(colors.red);
      overlayText = `Academic Ave: Yellow (${Math.max(
        0,
        yellowDuration - elapsed
      ).toFixed(1)}s)`;
      if (elapsed > yellowDuration) {
        state = 2;
        elapsed = 0;
      }
      break;

    case 2: // Academic Ave: Red, Bravado Blvd: Green
      LA.redLight.material.color.set(colors.red);
      LB.greenLight.material.color.set(colors.green);
      overlayText = `Bravado Blvd: Green (${Math.max(
        0,
        greenDuration - elapsed
      ).toFixed(1)}s)`;
      if (elapsed > greenDuration) {
        state = 3;
        elapsed = 0;
      }
      break;

    case 3: // Academic Ave: Red, Bravado Blvd: Yellow
      LA.redLight.material.color.set(colors.red);
      LB.yellowLight.material.color.set(colors.yellow);
      overlayText = `Bravado Blvd: Yellow (${Math.max(
        0,
        yellowDuration - elapsed
      ).toFixed(1)}s)`;
      if (elapsed > yellowDuration) {
        state = 0;
        elapsed = 0;
      }
      break;
  }
  overlay.innerHTML = overlayText;
}

// Animation loop
function animate() {
  requestAnimationFrame(animate);
  elapsed += clock.getDelta();
  updateTrafficLights();
  if (controls) controls.update();
  renderer.render(scene, camera);
}

// Start the animation
animate();
