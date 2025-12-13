// File: shaders/glass.gdshader
// Commit: Fix Godot 4.5 world-position access by passing from vertex to fragment; finalize glass window shader.

shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back;

uniform float opacity : hint_range(0.0, 1.0) = 0.12;
uniform float roughness : hint_range(0.0, 1.0) = 0.04;
uniform float metallic : hint_range(0.0, 1.0) = 1.0;
uniform float specular : hint_range(0.0, 1.0) = 0.9;

uniform float fresnel_power : hint_range(0.5, 10.0) = 5.0;
uniform float fresnel_boost : hint_range(0.0, 2.0) = 1.0;

uniform vec3 tint : source_color = vec3(0.85, 0.95, 1.0);

// World position passed from vertex shader
varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec3 V = normalize(CAMERA_POSITION_WORLD - world_pos);
    vec3 N = normalize(NORMAL);

    float ndv = clamp(dot(N, V), 0.0, 1.0);
    float fresnel = pow(1.0 - ndv, fresnel_power) * fresnel_boost;

    float alpha = clamp(opacity + fresnel * 0.35, 0.0, 1.0);

    ALBEDO = tint;
    METALLIC = metallic;
    ROUGHNESS = roughness;
    SPECULAR = specular;
    ALPHA = alpha;
}

