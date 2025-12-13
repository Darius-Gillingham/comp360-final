shader_type spatial;

// how many downward triangles stacked vertically
uniform float repeat_count = 10.0;

// shape size
uniform float tri_width  = 0.3;   // makes it thick or narrow
uniform float tri_height = 0.5;   // vertical size

// gap between rows (0 = touching, 0.1 = spaced slightly)
uniform float row_gap = 0.002;

uniform vec3 tri_color = vec3(0.0, 1.0, 0.0); // green

// downward triangle
float triangle_down(vec2 uv) {
    // repeat along Y
    uv.y *= repeat_count;
    uv.y = fract(uv.y + row_gap);

    // repeat along Y
    uv.x *= repeat_count;
    uv.x = fract(uv.x + row_gap);

    // normalize x in [-1, 1], y in [0, 1]
    float x = (uv.x / tri_width) * 2.0 - 1.0;
    float y = uv.y / tri_height;

    // filled downward triangle condition:
    //  y <= 1 - abs(x)
    //  0 <= y <= 1
    float inside =
        step(0.0, y) *
        step(y, 1.0) *
        step(y, 1.0 - abs(x));

    return inside;
}

void fragment() {
    vec2 uv = vec2(VERTEX.x, VERTEX.y);

    float mask = triangle_down(uv);

    vec3 base = vec3(1.0); // white background
    ALBEDO = mix(base, tri_color, mask);
}
