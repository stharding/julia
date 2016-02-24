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
#define complexMult(a,b)       vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x)
#define complexMag(z)          float(pow(length(z), 2.0))
#define complexReciprocal(z)   vec2(z.x / complexMag(z), -z.y / complexMag(z))
#define complexDivision(a,b)   complexMult(a, complexReciprocal(b))
#define complexArg(z)          float(atan(z.y, z.x))
#define complexLog(z)          vec2(log(length(z)), complexArg(z))
#define complexExp(z)          vec2(exp(z.x) * cos(z.y), exp(z.x) * sin(z.y))
#define sinh(x)                float((exp(x) - exp(-x)) / 2.0)
#define cosh(x)                float((exp(x) + exp(-x)) / 2.0)
#define complexSin(z)          vec2(sin(z.x) * cosh(z.y), cos(z.x) * sinh(z.y))
#define complexCos(z)          vec2(cos(z.x) * cosh(z.y), -sin(z.x) * sinh(z.y))
#define complexTan(z)          vec2(sin(2.0 * z.x)/(cos(2.0 * z.x) + cosh(2.0 * z.y)), sinh(2.0 * z.y)/(cos(2.0 * z.x) + cosh(2.0 * z.y)))
#define complexSinh(z)         vec2(sinh(z.x) * cos(z.y), cosh(z.x) * sin(z.y))
#define complexCosh(z)         vec2(cosh(z.x) * cos(z.y), sinh(z.x) * sin(z.y))
#define complexTanh(z)         vec2(sinh(2.0 * z.x)/(cosh(2.0 * z.x) + cos(2.0 * z.y)), sin(2.0 * z.y)/(cosh(2.0 * z.x) + cos(2.0 * z.y)))
#define polar(r,a)             vec2(cos(a) * r, sin(a) * r)
#define complexPower(z,p)      vec2(polar(pow(length(z), float(p)), float(p) * complexArg(z)))
#define complexPower2(z, p)    vec2(complexExp(complexMult(p, complexLog(z))))

vec3 julia( float x, float y ) {
  float z = 0.0;
  float xtemp;
  vec2  c  = vec2( cRe, cIm );
  vec2  xy = vec2( x, y );
  float thresh = 0.01;

  for(float i = 0.0; i < 100000.0; i++)
  {
    // vec2 tmp = xy - complexDivision( (complexExp(xy) - c), complexExp(xy) );
    // vec2 tmp = xy - complexDivision( (complexSinh(xy) - c), complexCosh(xy) );
    // vec2 tmp = xy - complexMult( c, complexDivision( (complexPower(xy, power.y) - 3.0 * xy),
    //                                  (power.y * complexPower(xy, power.y - 1.0) - 3.0) ) );
vec2 tmp = xy - complexDivision( (complexPower2(xy, power) - c),
    (complexMult( (power * (power - 0.1)), complexPower(xy, power - 2.0) ) ) );



    // vec2 tmp = xy - complexDivision( (complexPower2(xy, power) - c - complexSin(xy) ),
    //                                  ( (complexMult( power, complexPower(xy, power - 1.0) ) ) - complexCos(xy) ) );
    // vec2 tmp = xy - complexMult( c, complexDivision( (complexPower(xy, power.x) - 1.0),
    //                                  (power.x * complexPower(xy, power.x - 1.0)) ) );
z = i;
if ( abs(complexMag( tmp - xy) ) < thresh || i >= max ) break;
xy = tmp;
    // if(complexMag(xy) > 4.0 || i >= max) break;
    // z = i;
  }
  return vec3(xy.x, xy.y, z);
}

float affine( float i, float x, float I, float o, float O)
{
  return ((x - i) / (I - i)) * (O - o) + o;
}

vec4 hsvToRgb(float h, float s, float v)
{
  float r, g, b;

  float i = floor(h * 6.0);
  float f = h * 6.0 - i;
  float p = v * (1.0 - s);
  float q = v * (1.0 - f * s);
  float t = v * (1.0 - (1.0 - f) * s);
  float j = mod(i, 6.0);

  if ( j == 0.0 ) return vec4( v, t, p, 1.0 );
  if ( j == 1.0 ) return vec4( q, v, p, 1.0 );
  if ( j == 2.0 ) return vec4( p, v, t, 1.0 );
  if ( j == 3.0 ) return vec4( p, q, v, 1.0 );
  if ( j == 4.0 ) return vec4( t, p, v, 1.0 );
  if ( j == 5.0 ) return vec4( v, p, q, 1.0 );

  return vec4( 1.0, 1.0, 1.0, 1.0 );
}

vec4 getcolor(vec3 xyz)
{
  float z = xyz.z / max;
  // if ( z < 0.02 ) return vec4( xyz.x, xyz.x, xyz.x, z );
  vec4 grey = vec4( z, z, z, 1 );
  // return grey + vec4( xyz.xy/max, (xyz.x + xyz.y)/max, 1 );
  return grey + hsvToRgb( xyz.y, 0.7, 0.5 );
}

void main()
{
  float current_scale = (maxX - minX) / width;
  float x       = (gl_FragCoord.x * current_scale) + minX;
  float y       = (gl_FragCoord.y * current_scale) + minY;

  gl_FragColor = getcolor( julia( x, y ) );
}
