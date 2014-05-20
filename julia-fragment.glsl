#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform float cRe;
uniform float cIm;
uniform float minX;
uniform float maxX;
uniform float minY;
uniform float width;
uniform float max;
uniform float power;

float julia( float x, float y ) {
  float z = 0.0;
  float xtemp;
  for(float i = 0.0; i < 100000.0; i++)
  {
    if ( power == 2.0 ) {
      xtemp = x * x - y * y + cRe;
      y = 2.0 * x * y + cIm;      
    } else if ( power == 3.0 ) {
      xtemp = x*x*x - 3.0*x*y*y+cRe;
      y = 3.0 * x*x*y - y*y*y+cIm;
    } else if ( power == 4.0 ) {
      xtemp = x*x*x*x - 6.0*x*x*y*y + y*y*y*y + cRe;
      y = 4.0*x*x*x*y - 4.0*x*y*y*y + cIm;
    }
    x = xtemp;
    if((x * x + y * y) > 4.0 || i >= max) break;
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