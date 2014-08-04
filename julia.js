var canvas                               ,
    gl                                   ,
    program                              ,
    vBuff                                ,
    vPosition                            ,
    cxPosition                           ,
    cyPosition                           ,
    minXposition                         ,
    maxXposition                         ,
    minYposition                         ,
    WIDTH                                ,
    re_label                             ,
    im_label                             ,
    f2, f3, f4, f5                       ,
    power      = vec2(2, 0)              ,
    x_factor   = 1                       ,
    y_factor   = 1                       ,
    hslMode    = false                   ,
    m_down     = false                   ,
    zoom_step  = 1-1e-1                  ,
    first      = true                    ,
    scale      =  1.9                    ,
    cx         =  0                      ,
    cy         =  0                      ,
    cRe        = -0.7                    ,
    cIm        =  0.27015                ,
    ox         = cx                      ,
    oy         = cy                      ,
    iterations = 100                     ,
    minX       = cx - (x_factor * scale) ,
    maxX       = cx + (x_factor * scale) ,
    minY       = cy - (y_factor * scale) ;

window.onload      = init;
window.onresize    = init;
window.onkeydown   = handle_on_key_down;

function init()
{
    if (first) canvas = document.getElementById( "gl-canvas" );
    var maxHeight = window.innerHeight * 0.9;
    var maxWidth  = window.innerWidth * 0.9;
    var dimension = maxHeight < maxWidth ? maxHeight : maxWidth;
    var pixelRatio = window.devicePixelRatio || 1;

    canvas.style.width  = dimension + "px";
    canvas.style.height = dimension + "px";

    canvas.width = canvas.clientWidth * pixelRatio;
    canvas.height = canvas.clientHeight * pixelRatio;
    WIDTH  = canvas.width;

    canvas.onmousedown = handle_mouse_down;
    canvas.onmouseup   = function () { m_down = false; };
    canvas.onmousemove = handle_mouse_move;

    canvas.onmousewheel = handleWheel;
    if (first)
    {
        
        gl = WebGLUtils.setupWebGL( canvas );
        if ( !gl ) { alert( "WebGL isn't available" ); }

        //  Load shaders and initialize attribute buffers
        program = initShaders( gl, "julia-vertex.glsl", "julia-fragment.glsl" );
        gl.useProgram( program );

        vBuff          = gl.createBuffer();
        vPosition      = gl.getAttribLocation ( program, "vPosition" ); 
        cxPosition     = gl.getUniformLocation( program, "cRe"       );
        cyPosition     = gl.getUniformLocation( program, "cIm"       );
        minXposition   = gl.getUniformLocation( program, "minX"      ); 
        maxXposition   = gl.getUniformLocation( program, "maxX"      ); 
        minYposition   = gl.getUniformLocation( program, "minY"      ); 
        widthPosition  = gl.getUniformLocation( program, "width"     ); 
        iterPosition   = gl.getUniformLocation( program, "max"       );    
        hslPosition    = gl.getUniformLocation( program, "hslMode"   );
        powerPosition  = gl.getUniformLocation( program, "power"     );
    }
    first = false;

    re_label = document.getElementById( "re_label" );
    im_label = document.getElementById( "im_label" );
    f2       = document.getElementById( "f2" );
    f3       = document.getElementById( "f3" );
    f4       = document.getElementById( "f4" );
    f5       = document.getElementById( "f5" );

    points = [
      vec2( -1,  1 ),
      vec2( -1, -1 ),
      vec2(  1, -1 ),
      vec2(  1,  1 )
    ]

    gl.viewport( 0, 0, canvas.width, canvas.height );
    gl.clearColor( 1, 1, 1, 1.0 );

    gl.bindBuffer( gl.ARRAY_BUFFER, vBuff );
    gl.bufferData( gl.ARRAY_BUFFER, flatten(points), gl.STATIC_DRAW );
    gl.enableVertexAttribArray( vPosition );
    gl.vertexAttribPointer( vPosition, 2, gl.FLOAT, false, 0, 0);
    gl.uniform1f( widthPosition , canvas.width  );
    gl.uniform1f( iterPosition, iterations );
    gl.uniform1i( hslPosition, hslMode );

    render()
}

function render ()
{
  gl.clear     ( gl.COLOR_BUFFER_BIT     );
  gl.uniform1f ( cxPosition      , cRe   );
  gl.uniform1f ( cyPosition      , cIm   );
  gl.uniform1f ( minXposition    , minX  );
  gl.uniform1f ( maxXposition    , maxX  );
  gl.uniform1f ( minYposition    , minY  );
  gl.uniform2fv( powerPosition   , power );
  gl.bindBuffer( gl.ARRAY_BUFFER , vBuff );
  gl.drawArrays( gl.TRIANGLE_FAN , 0, points.length );
}

function handleWheel( e )
{
  var s = e.wheelDelta;
  scale = s > 0 ? scale * 0.95: scale / 0.95;
  setWindow()
  render()
  return false;
}

function handle_on_key_down( e )
{
  var x = document.activeElement;
  switch ( e.keyCode )
  {
    /* up */ case 38: u_pressed  = true; handle_up    ( e ); return false;
    /* dn */ case 40: d_pressed  = true; handle_down  ( e ); return false;
    /* lf */ case 39: r_pressed  = true; handle_right ( e ); return false;
    /* rt */ case 37: l_pressed  = true; handle_left  ( e ); return false;
    /*  1 */ case 49: iterations =  100;  gl.uniform1f( iterPosition, iterations ); render(); break;
    /*  2 */ case 50: iterations =  200;  gl.uniform1f( iterPosition, iterations ); render(); break;
    /*  3 */ case 51: iterations =  500;  gl.uniform1f( iterPosition, iterations ); render(); break;
    /*  4 */ case 52: iterations = 1000;  gl.uniform1f( iterPosition, iterations ); render(); break;
    /*  5 */ case 53: iterations = 2000;  gl.uniform1f( iterPosition, iterations ); render(); break;
    /*  6 */ case 54: iterations = 8000;  gl.uniform1f( iterPosition, iterations ); render(); break;
    /*  - */ case 189: iterations -= 100; gl.uniform1f( iterPosition, iterations ); render(); break;
    /*  + */ case 187: iterations += 100; gl.uniform1f( iterPosition, iterations ); render(); break;
  }
}

function handle_up( e )
{
  if ( e.shiftKey ) scale *= zoom_step; 
  else   cy += 0.1 * scale;
  setWindow();
  render();
}
function handle_down( e )
{
  if ( e.shiftKey ) scale /= zoom_step; 
  else cy -= 0.1 * scale;
  setWindow();
  render();
}
function handle_right( e )
{
  cx += 0.1 * scale;
  setWindow();
  render();
}
function handle_left( e )
{
  cx -= 0.1 * scale;
  setWindow();
  render();
}

function handle_mouse_down ( e ) {
  m_down = true;
  ox = e.hasOwnProperty('offsetX') ? e.offsetX : e.layerX;
  oy = e.hasOwnProperty('offsetY') ? e.offsetY : e.layerY;
}

var firstMouseMove = true;
function handle_mouse_move ( e ) 
{
  if ( m_down ) {
    var dx = ox - (e.offsetX==undefined?e.layerX:e.offsetX);
    var dy = (e.offsetY==undefined?e.layerY:e.offsetY) - oy;

    ox = e.offsetX==undefined?e.layerX:e.offsetX;
    oy = e.offsetY==undefined?e.layerY:e.offsetY;
    if ( e.shiftKey ) {
      cRe += dx/100;
      cIm += dy/100;
      re_label.innerHTML = cRe;
      im_label.innerHTML = cIm;
    } else if ( e.altKey ) {
      power[0] += dx/100;
      power[1] += dy/100;
    } else {
      cx += 4 * dx / (canvas.width  / scale );
      cy += 4 * dy / (canvas.height / scale );
      setWindow();     
    }
    render();
  }
}

function setWindow()
{
  minX  = cx - (x_factor * scale);
  maxX  = cx + (x_factor * scale);
  minY  = cy - (y_factor * scale);
}

function changeFunction()
{
  if (f2.checked) power = vec2(2.0, 0);
  if (f3.checked) power = vec2(3.0, 0);
  if (f4.checked) power = vec2(4.0, 0);
  if (f5.checked) power = vec2(5.0, 0);
  render()
}