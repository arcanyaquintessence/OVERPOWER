shader_type spatial;

uniform vec3 color:source_color;
uniform vec3 color2:source_color;

uniform sampler2D noise;
uniform float noiseScale = 20.0;

varying vec3 worldPos;

uniform float sway_speed = 1.0;
uniform float sway_strength = 0.05;
uniform float sway_phase_len = 8.0;

void vertex() {
    float strength = COLOR.r * sway_strength;
    VERTEX.x += sin(VERTEX.x * sway_phase_len * 1.123 + TIME * sway_speed) * strength;
    VERTEX.y += tan(sin(VERTEX.y * sway_phase_len + TIME * sway_speed * 1.12412) * strength);
    VERTEX.z += sin(VERTEX.z * sway_phase_len * 0.9123 + TIME * sway_speed * 1.3123) * strength;
}

void fragment(){
	vec3 noiseLevel = texture(noise, worldPos.xz/noiseScale).rgb;
	ALBEDO = mix(color, color2, UV.y) * mix(color, color2, noiseLevel.r);
}