import GUI from "lil-gui";
import * as THREE from "three";
import { Renderer } from "./lib/renderer";
import vertexShader from "./shaders/vertex.glsl?raw";
import fragmentShader from "./shaders/fragment.glsl?raw";

const canvas = document.getElementById("webgl-canvas") as HTMLCanvasElement;

if (!canvas) {
  throw new Error("Canvas element not found");
}

const gui = new GUI();
const renderer = new Renderer(canvas);

const config = {
  wireframe: false,
  uSpeed: 0.2,
  uColor: "#ffffff",
};

const mesh = new THREE.Mesh(
  new THREE.BoxGeometry(4, 4, 4, 100, 100, 100),
  new THREE.ShaderMaterial({
    wireframe: config.wireframe,
    vertexShader,
    fragmentShader,
    uniforms: {
      uTime: { value: 0 },
      uSpeed: { value: config.uSpeed },
      uColor: { value: new THREE.Color(config.uColor) },
      uResolution: { value: new THREE.Vector2(canvas.width, canvas.height) },
    },
  }),
);

renderer.scene.add(mesh);

const clock = new THREE.Clock();

// Animation loop
renderer.animate(() => {
  (mesh.material as THREE.ShaderMaterial).uniforms.uTime.value =
    clock.getElapsedTime();
});

gui.add(config, "wireframe").onChange((value: boolean) => {
  (mesh.material as THREE.ShaderMaterial).wireframe = value;
});

gui.add(config, "uSpeed", 0, 2, 0.1).onChange((value: number) => {
  (mesh.material as THREE.ShaderMaterial).uniforms.uSpeed.value = value;
});

gui.addColor(config, "uColor").onChange((value: string) => {
  (mesh.material as THREE.ShaderMaterial).uniforms.uColor.value.set(value);
});

window.addEventListener("resize", () => {
  (mesh.material as THREE.ShaderMaterial).uniforms.uResolution.value.set(
    window.innerWidth,
    window.innerHeight,
  );
});
