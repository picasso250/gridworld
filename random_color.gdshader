shader_type canvas_item;

void fragment() {
    vec3 random_color = vec3(
        fract(sin(TIME + UV.x * 12.9898) * 43758.5453),
        fract(sin(TIME + UV.y * 78.233) * 43758.5453),
        fract(sin(TIME + UV.x * UV.y * 24.654) * 43758.5453)
    );
    COLOR = vec4(random_color, 1.0);
}
