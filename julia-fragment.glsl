#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

uniform float cRe;
uniform float cIm;
uniform float minX;
uniform float maxX;
uniform float minY;
uniform float width;
uniform float max;
uniform vec2  power;

// Complex math operations
#define complexMult(a,b) vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x)
#define complexMag(z) float(pow(length(z), 2.0))
#define complexReciprocal(z) vec2(z.x / complexMag(z), -z.y / complexMag(z))
#define complexDivision(a,b) complexMult(a, complexReciprocal(b))
#define complexArg(z) float(atan(z.y, z.x))
#define complexLog(z) vec2(log(length(z)), complexArg(z))
#define complexExp(z) vec2(exp(z.x) * cos(z.y), exp(z.x) * sin(z.y))
#define sinh(x) float((exp(x) - exp(-x)) / 2.0)
#define cosh(x) float((exp(x) + exp(-x)) / 2.0)
#define complexSin(z) vec2(sin(z.x) * cosh(z.y), cos(z.x) * sinh(z.y))
#define complexCos(z) vec2(cos(z.x) * cosh(z.y), -sin(z.x) * sinh(z.y))
#define complexTan(z) vec2(sin(2.0 * z.x)/(cos(2.0 * z.x) + cosh(2.0 * z.y)), sinh(2.0 * z.y)/(cos(2.0 * z.x) + cosh(2.0 * z.y)))
#define complexSinh(z) vec2(sinh(z.x) * cos(z.y), cosh(z.x) * sin(z.y))
#define complexCosh(z) vec2(cosh(z.x) * cos(z.y), sinh(z.x) * sin(z.y))
#define complexTanh(z) vec2(sinh(2.0 * z.x)/(cosh(2.0 * z.a) + cos(2.0 * z.y)), sin(2.0 * z.y)/(cosh(2.0 * z.x) + cos(2.0 * z.y)))
#define polar(r,a) vec2(cos(a) * r, sin(a) * r)
#define complexPower(z,p) vec2(polar(pow(length(z), float(p)), float(p) * complexArg(z)))

// x^y = exp(y * log(x))
#define complexPower2(z, p) vec2(complexExp(complexMult(p, complexLog(z))))

float julia( float x, float y ) {
  float z = 0.0;
  float xtemp;
  vec2  c  = vec2( cRe, cIm );
  vec2  xy = vec2( x, y );

  for(float i = 0.0; i < 100000.0; i++)
  {
    xy = complexPower2( xy, vec2(power) ) + c;
    if(dot(xy, xy) > 4.0 || i >= max) break;
    z = i;
  }
  return z;
}

vec4 getcolor(float z)
{
  if (z == max - 1.0) return vec4(0,0,0,1);
  z/=(max/3.0);
  float r = z + z > 1.0 ? z / (z + z) : z + z;
  float g = z     > 1.0 ? 1.0 / (z * z) : z;
  float b = z     > 1.0 ? 1.0 / z       : z * z;
  return vec4(r, g, b, 1.0);
}

void main()
{
  float current_scale = (maxX - minX) / width;
  float x       = (gl_FragCoord.x * current_scale) + minX;
  float y       = (gl_FragCoord.y * current_scale) + minY;

  gl_FragColor = getcolor( julia( x, y ) );
}