shader_type canvas_item;

uniform vec4 gas_color;
uniform float noise_scale = 1.0; // 噪声放大倍数
uniform float speed = 0.0000001; // 控制布朗运动的速度

// 随机数生成函数
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // 布朗运动的偏移值，每帧随机扰动
    vec2 uv = UV * noise_scale;
    float time_offset = TIME * speed;
    
    // 随机方向和随机幅度
    vec2 brownian_offset;
    brownian_offset.x = sin(random(uv + time_offset));
    brownian_offset.y = cos(random(uv - time_offset));

    uv += brownian_offset * random(uv + time_offset); // 添加布朗运动偏移

    // 计算噪声
    float noise = random(uv);

    // 混合颜色
    vec4 color = gas_color * noise;
    color.a *= smoothstep(0.3, 0.7, noise); // 控制透明度变化

    COLOR = color;
}
