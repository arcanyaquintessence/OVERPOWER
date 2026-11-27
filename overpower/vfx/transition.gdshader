//by pixeldreamerstudio
shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 ink_color : source_color = vec4(0.045, 0.04, 0.055, 1.0);
uniform float angle : hint_range(-180.0, 180.0) = -10.0;
uniform int stroke_count : hint_range(1, 12) = 5;
uniform float edge_softness : hint_range(0.0, 1.0) = 0.2;
uniform float dry_brush : hint_range(0.0, 1.0) = 0.6;
uniform float splatter : hint_range(0.0, 1.0) = 0.5;
uniform float wash : hint_range(0.0, 1.0) = 0.4;
uniform bool invert = false;
uniform float rect_aspect : hint_range(0.25, 4.0) = 1.7778;
uniform float seed : hint_range(0.0, 100.0) = 0.0;

const float TAIL = 0.2;
const float STAGGER = 0.5;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float arrival(vec2 uv, out vec2 sl) {
	vec2 p = (uv - 0.5) * vec2(rect_aspect, 1.0);
	float a = radians(angle);
	vec2 dir = vec2(cos(a), sin(a));
	vec2 nor = vec2(-dir.y, dir.x);
	float hu = 0.5 * (rect_aspect * abs(dir.x) + abs(dir.y));
	float hv = 0.5 * (rect_aspect * abs(nor.x) + abs(nor.y));
	float su = dot(p, dir) / (2.0 * hu) + 0.5;
	float sv = dot(p, nor) / (2.0 * hv) + 0.5;
	float n = float(stroke_count);
	float lane = mix(0.1, n - 0.1, sv);
	float len = 2.0 * hu;
	float lw = 2.0 * hv / n;
	sl = vec2(su * len, lane);
	float d = (1.0 - TAIL) / (1.0 + (n - 1.0) * STAGGER);
	float lag = min(0.5 * d, TAIL * 0.7);
	float t = 9.0;
	float k0 = floor(lane);
	for (int i = -1; i <= 1; i++) {
		float k = k0 + float(i);
		if (k < 0.0 || k > n - 0.5) {
			continue;
		}
		float ks = k * 17.31 + seed * 7.13;
		float x = su * len;
		float centre = k + 0.5 + 0.26 * (vnoise(vec2(x * 1.3 + ks, ks)) - 0.5);
		float half_w = 0.74 + 0.16 * vnoise(vec2(x * 2.2 + ks + 31.7, ks + 3.0));
		float across = lane * lw;
		float bristle = vnoise(vec2(x * 1.6 + ks, across * 55.0 + ks));
		float fine = vnoise(vec2(x * 5.0 + ks, across * 170.0 - ks));
		float streak = bristle * bristle * (0.7 + 0.3 * fine);
		float dv = abs(lane - centre) + 0.14 * dry_brush * (bristle * 0.7 + fine * 0.3 - 0.5);
		float edge = clamp(dv / half_w, 0.0, 1.0);
		float along = mod(k, 2.0) < 0.5 ? su : 1.0 - su;
		float dry = dry_brush * streak * (0.25 + 0.75 * along) * (0.5 + 1.0 * edge * edge);
		float head = 0.07 * edge * edge;
		float outside = max(dv - half_w, 0.0) * 2.0;
		float tk = k * STAGGER * d + d * (along * 0.9 + head) + lag * min(dry, 1.0) + outside;
		t = min(t, tk);
	}
	return clamp(t, 0.0, 1.0);
}

float drops(vec2 uv, float cells, float pm, float soft, float layer_seed) {
	vec2 p = uv * vec2(rect_aspect, 1.0) * cells;
	vec2 cell = floor(p);
	vec2 f = fract(p);
	vec2 cs = cell + layer_seed + seed * 3.7;
	float h = hash(cs);
	if (h > splatter * 0.5) {
		return 0.0;
	}
	vec2 c = 0.25 + 0.5 * vec2(hash(cs + 1.7), hash(cs + 5.3));
	float h2 = hash(cs + 9.1);
	float r = 0.035 + 0.17 * h2 * h2 * h2;
	vec2 centre_uv = (cell + c) / (vec2(rect_aspect, 1.0) * cells);
	vec2 unused;
	float td = max(arrival(centre_uv, unused) - 0.01 - 0.035 * hash(cs + 2.9), 0.0);
	float grow = smoothstep(td - soft, td + soft, pm);
	vec2 dd = f - c;
	float rr = r * (1.0 + 0.25 * (vnoise(vec2(atan(dd.y, dd.x) * 1.6, h * 50.0)) - 0.5));
	return (1.0 - smoothstep(rr * 0.7, rr, length(dd))) * grow;
}

void fragment() {
	float pr = clamp(progress, 0.0, 1.0);
	float soft = 0.002 + 0.03 * edge_softness;
	float pm = mix(-soft, 1.0 + soft, pr);
	vec2 sl;
	float t = arrival(UV, sl);
	float cover = smoothstep(t - soft, t + soft, pm);
	if (splatter > 0.001) {
		cover = max(cover, drops(UV, 9.0, pm, soft, 0.0));
		cover = max(cover, drops(UV, 21.0, pm, soft, 37.0));
	}

	float alpha = invert ? 1.0 - cover : cover;
	float full = invert ? 1.0 - pr : pr;
	float settle = smoothstep(0.7, 0.95, full);

	float lw = 1.0 / float(stroke_count);
	float inside = invert ? t - pm : pm - t;
	float rim = 1.0 - smoothstep(0.0, 0.05, inside);
	float lines = vnoise(vec2(sl.x * 2.5 + seed, sl.y * lw * 120.0)) * 0.65 + vnoise(vec2(sl.x * 0.9 - seed, sl.y * lw * 26.0)) * 0.35;
	float body = 1.0 - wash * 0.16 * smoothstep(0.35, 0.8, lines) * (1.0 - rim);

	alpha *= mix(body, 1.0, settle);
	COLOR = vec4(ink_color.rgb, ink_color.a * alpha);
}
