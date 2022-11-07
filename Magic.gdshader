shader_type canvas_item;
mat2 rot(float x)
{
	return mat2(vec2(cos(x), sin(x)),vec2(-sin(x), cos(x)));
}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

varying float mat;
varying float ss;

float map(vec3 p)
{
    p.x += sin(p.z * ss);
    p.y += cos(p.z * ss);
    
    float sc = (sin(p.z) * 0.5 + 1.0) * 0.5;
    
    vec3 r = p;
    
    r.xy = vec2(atan(r.x, r.y) / 3.14159265359 * 2.0, length(r.xy));
    
    r.x += r.z * 0.125;
    r.x = (fract(r.x) - 0.5) * 4.0;
    
    r.y -= 3.0;
    
    r.z = fract(r.z) - 0.5;
    
    vec3 q = r;
    float d = 1000.0;
    
    vec3 s = vec3(0.5, 0.125, 0.125);
    vec3 as = vec3(1.0, 0.0, 0.0);
    float u = 1.0;
    
    const int n = 4;
    for (int i = 0; i < n; ++i) {
        float fi = float(i) / float(n - 1);
        
        q = abs(q) - 0.3;

        q.xy *= rot(3.14159 * 0.125);
        
        float k = sdBox(q, s);
        
        if (k < d) {
            d = k;
          //  mat = float(i);
        }
        
        s = s.yzx * 0.75;
        as = as.yzx;
        u *= 0.5;
    }
    
    float c = 1.0 + r.y;
    
    d = max(d, -c);
    
	return d;
}

vec3 normal(vec3 p)
{
	vec3 o = vec3(0.01, 0.0, 0.0);
    return normalize(vec3(map(p+o.xyy) - map(p-o.xyy),
                          map(p+o.yxy) - map(p-o.yxy),
                          map(p+o.yyx) - map(p-o.yyx)));
}

float trace(vec3 o, vec3 r)
{
    float t = 0.0;
    for (int i = 0; i < 32; ++i) {
        t += map(o + r * t) * 0.6;
    }
    return t;
}

vec3 textex(sampler2D channel, vec3 p)
{
    vec3 ta = texture(channel, p.xy).xyz;
    vec3 tb = texture(channel, p.xz).xyz;
    vec3 tc = texture(channel, p.yz).xyz;
    return (ta * ta + tb * tb + tc * tc) / 3.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 o = vec3(0.0, 0.0, iTime * 4.0);
    o.x -= sin(o.z * ss);
    o.y -= cos(o.z * ss);
    
    vec3 r = normalize(vec3(uv, 1.0 - dot(uv, uv) * 0.33));

    r.xy *= rot(sin(o.z * ss * 0.5) * 3.14159 * 0.5);
    r.xz *= rot(sin(o.z * ss) * 3.14159 * 0.25);
    r.yz *= rot(cos(o.z * ss) * 3.14159 * 0.25);
    
    float t = trace(o, r);
    vec3 w = o + r * t;
    float fd = map(w);
    vec3 sn = normal(w);
    
    vec3 tex = textex(iChannel0, w);
    if (mat < 3.0) {
        tex *= 0.25;
    }
    
    vec3 sk = vec3(0.0);
    const int n = 8;
    for (int i = 0; i < n; ++i) {
        float fi = float(i + 1) / float(n + 1);
        float fr = o.z + fi * 4.0;
		vec3 sp = vec3(0.0, 0.0, floor(fr));
        fr = fract(fr);
        fr = 4.0 * fr * (1.0 - fr);
        float st = 0.0;
        for (int i = 0; i < 4; ++i) {
            vec3 sq = o + r * st - sp;
            st += 5.0 - length(sq);
        }
        vec3 sw = o + r * st - sp;
        sw.xz *= rot(3.14159 * 2.0 * fi);
        vec3 stex = textex(iChannel1, sw * 0.5);
        sk += stex * fr * 0.25;
    }
    
    vec3 ldir = normalize(vec3(1.0, 1.0, 1.0));
    vec3 ref = reflect(-ldir, sn);
    float prod = max(dot(r, ref), 0.0);
    prod = pow(prod, 4.0);
    vec3 pcol = textex(iChannel2, w * 0.1) * prod;
    
    float fog = 1.0 / (1.0 + t * t * 0.01);
    float edge = 1.0 / (1.0 + fd * 100.0);
    vec3 fc = (tex * fog + pcol) * edge;
    
    fc = mix(fc, sk, 1.0 - fog);
    
    vec3 nfc = vec3(dot(fc, vec3(0.299, 0.587, 0.114)));
    nfc.y += fc.y * 0.25;
    nfc.x += fc.z * 0.5;
    nfc.z += fc.x * 0.75;
    nfc *= 2.0;
    
	fragColor = vec4(sqrt(nfc), 1.0);
}