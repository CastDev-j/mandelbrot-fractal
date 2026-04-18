precision highp float;

varying vec2 vUv;
varying vec3 vWorldPos;
varying vec3 vNormalW;
varying vec3 vObjectPos;

uniform vec3 uColor;
uniform float uTime;
uniform float uSpeed;
uniform vec2 uResolution;

vec2 cmul(vec2 a, vec2 b) {
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 mandelbrot(vec2 c) {
    vec2 z = vec2(0.0);
    float iter = 0.0;
    float r2 = 0.0;

    for(int i = 0; i < 120; i++) {
        z = cmul(z, z) + c;
        r2 = dot(z, z);
        if(r2 > 64.0) {
            iter = float(i);
            break;
        }
        iter = float(i);
    }

    if(r2 > 64.0) {
        float smoothIter = iter + 1.0 - log2(log2(sqrt(r2)));
        return vec2(smoothIter / 120.0, 0.0);
    }
    return vec2(1.0, 1.0);
}

vec2 mapToComplex(vec2 p, float zoom, vec2 offset) {
    return p * zoom + offset;
}

void main() {
    vec3 n = normalize(vNormalW);
    vec3 absN = abs(n);
    vec3 p = vObjectPos * 2.0;

    vec2 faceUV;
    if(absN.x > absN.y && absN.x > absN.z) {
        faceUV = vec2(p.z * sign(n.x), p.y);
    } else if(absN.y > absN.z) {
        faceUV = vec2(p.x * sign(n.y), p.z);
    } else {
        faceUV = vec2(p.x * sign(n.z), p.y);
    }

    float zoom = 1.28 * exp(-uTime * uSpeed * 0.08);
    vec2 offset = vec2(-0.745, 0.186);

    vec2 c = mapToComplex(faceUV, zoom, offset);
    vec2 m = mandelbrot(c);

    float escape = clamp(m.x, 0.0, 1.0);
    float inside = m.y;

    float branchPat = 1.0 - abs(sin(escape * 58.0));
    float branchMask = smoothstep(0.72, 0.96, branchPat) * (1.0 - inside);

    float blackMask = max(branchMask, inside);
    vec3 col = mix(uColor, vec3(0.0), blackMask);

    gl_FragColor = vec4(col, 1.0);
}