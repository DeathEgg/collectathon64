// Shader code from https://github.com/Calinou/godot-simulated-banding-demo

shader_type spatial;

#define LIT diffuse_lambert, vertex_lighting
#define DEPTH depth_draw_opaque
#define BLEND blend_mix
#define METAL

#include "n64_base.gdshaderinc"
