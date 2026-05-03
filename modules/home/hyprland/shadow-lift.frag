#version 300 es
// Hyprland screen shader: lift dark regions, leave highlights alone.
//
// SHADOW_LIFT  — how much to brighten shadows. 0 = off, 0.3 = subtle,
//                0.5 = noticeable, 0.7+ = washed out.
// SHADOW_KNEE  — luminance (0..1) above which no lift is applied. Lower
//                = only deep blacks lifted; higher = midtones too.
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

const float SHADOW_LIFT = 0.28;
const float SHADOW_KNEE = 0.35;

void main() {
    vec4 color = texture(tex, v_texcoord);
    float luma = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722)); // Rec.709
    // mask = 1 at black, smooth ramp to 0 at SHADOW_KNEE
    float mask = 1.0 - smoothstep(0.0, SHADOW_KNEE, luma);
    // gamma < 1 brightens; modulated by mask so highlights stay at gamma=1
    float gamma = mix(1.0, 1.0 - SHADOW_LIFT, mask);
    vec3 lifted = pow(max(color.rgb, vec3(0.0)), vec3(gamma));
    fragColor = vec4(lifted, color.a);
}
