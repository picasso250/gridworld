shader_type canvas_item;

uniform int type : hint_range(0, 3); // 0 - solid, 1 - liquid, 2 - gas, 3 - vacuum
uniform vec4 solid_color = vec4(0.5, 0.5, 0.5, 1.0); // 固体颜色
uniform vec4 liquid_color = vec4(0.0, 0.0, 1.0, 1.0); // 液体的颜色
uniform float liquid_amount = 1.0; // 液体的量
uniform vec4 gas_color = vec4(1.0, 1.0, 1.0, 1.0); // 气体的颜色
uniform float noise_scale = 1.0; // 噪声放大倍数
uniform float speed = 0.0000001; // 布朗运动的速度
uniform vec4 vacuum_color = vec4(0.9, 0.9, 0.9, 0.0); // 真空颜色（完全透明）

// 随机数生成函数
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    if (type == 0) {
        // 固体渲染
        COLOR = solid_color; // 固体直接显示固体颜色
    } else if (type == 1) {
        // 液体渲染
        vec4 color = liquid_color;
        float visible_amount = max(liquid_amount, 0.05); // 最小可见液体量为5%

        // 液体显示区域
        if (UV.y > (1.0 - visible_amount)) {
            color.a = 1.0; // 完全不透明
        } else {
            color.a = 0.0; // 透明
        }

        COLOR = color;
    } else if (type == 2) {
        // 气体渲染
        vec2 uv = UV * noise_scale;
        float time_offset = TIME * speed;
        
        // 布朗运动偏移
        vec2 brownian_offset;
        brownian_offset.x = sin(random(uv + time_offset));
        brownian_offset.y = cos(random(uv - time_offset));
        uv += brownian_offset * random(uv + time_offset);

        // 计算噪声
        float noise = random(uv);
        
        // 混合颜色
        vec4 color = gas_color * noise;
        color.a *= smoothstep(0.3, 0.7, noise); // 控制透明度变化

        COLOR = color;
    } else if (type == 3) {
        // 真空渲染
        // 真空使用类似固体的渲染方式，但透明度为0
        COLOR = vacuum_color; // 真空完全透明
    }
}
