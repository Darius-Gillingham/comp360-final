shader_type spatial;
render_mode specular_schlick_ggx;

uniform vec4 albedo_color : source_color = vec4(0.92, 0.94, 1.0, 1.0);
uniform float roughness : hint_range(0.01, 0.2) = 0.08;
uniform float metallic : hint_range(0.0, 1.0) = 1.0;
uniform float clearcoat : hint_range(0.0, 1.0) = 0.6;
uniform float clearcoat_roughness : hint_range(0.01, 0.2) = 0.05;

void fragment() {
	ALBEDO = albedo_color.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	CLEARCOAT = clearcoat;
	CLEARCOAT_ROUGHNESS = clearcoat_roughness;
}
