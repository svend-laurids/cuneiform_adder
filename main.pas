program main;
uses
	Classes, SysUtils, SDL2, SDL2_image, GL, GLext,
	babylonian_math in './babylonian_math.pas',
	openglhelper in './openglhelper.pas',
	ImagingTypes, Imaging;
const (* MAIN *)
	vertexShaderFile = 'VertexShader.txt';
	fragmentShaderFile = 'FragmentShader.txt';
var (* MAIN *)
	i, u, charx, chary, numofquads, err : Integer;
	addend1, addend2 : LongInt;
	sdlWindow : PSDL_Window;
	sdlEvent : PSDL_Event;
	sdlGLContext : TSDL_GLContext;
	programHandle, textureHandle : GLuint;
	VAO, quadVBO, quadEBO : GLuint;
	vertices : Array of Single;
	indices : Array of GLubyte;
	resolution : Array[0..1] of GLfloat;
	quit : Boolean;
	addend1baby, addend2baby, sumbaby : Babylonian;
begin (* MAIN *)
	if ParamCount() <> 2 then begin
		WriteLn('usage : main.exe addend1 addend2');
		exit();
	end;
	Val(ParamStr(1), addend1, err);
	Val(ParamStr(2), addend2, err);

	addend1baby := Babylonian_Set(addend1);
	addend2baby := Babylonian_Set(addend2);
	sumbaby := Babylonian_Set((addend1 + addend2));

	resolution[0] := sumbaby.digits*128;
	resolution[1] := 192;

	scc(SDL_Init(SDL_INIT_EVERYTHING));
	sdlWindow := scp(SDL_CreateWindow('Cuneiform adder', 100, 100, sumbaby.digits*128, 192, SDL_WINDOW_OPENGL)); 
	sdlGLContext := scp(SDL_GL_CreateContext(sdlWindow));
	if Load_GL_VERSION_4_0 = false then
		if Load_GL_VERSION_3_3 = false then
			if Load_GL_VERSION_3_2 = false then
				if Load_GL_VERSION_3_0 = false then
					begin
						WriteLn('ERROR : OpenGL 3.0 or higher needed');
						Halt(0);
					end;
(*
	WriteLn('Vendor: ', glGetString(GL_VENDOR));
	WriteLn('OpenGL Version: ', glGetString(GL_VERSION));
	WriteLn('Shader Version: ', glGetString(GL_SHADING_LANGUAGE_VERSION));
*)
	numofquads := addend1baby.digits + addend2baby.digits + sumbaby.digits;

	SetLength(vertices, numofquads*16);
	SetLength(indices, numofquads*6);

	i := 0;
	u := 0;
	while (u <> addend1baby.digits) do begin 
		(*x*)
		vertices[0+16*i] := 128.0*(sumbaby.digits-u-1); 
		vertices[4+16*i] := 128.0*(sumbaby.digits-u); 
		vertices[8+16*i] := 128.0*(sumbaby.digits-u-1); 
		vertices[12+16*i] := 128.0*(sumbaby.digits-u); 
		(*y*)
		vertices[1+16*i] := 192; 
		vertices[5+16*i] := 192; 
		vertices[9+16*i] := 128; 
		vertices[13+16*i] := 128; 
		(*texture*)
		(*x*)
		charx := ((addend1baby.value[u]-1) mod 8);
		vertices[2+16*i] := 128*(charx);
		vertices[6+16*i] := 128.0*(charx+1); 
		vertices[10+16*i] := 128.0*(charx);
		vertices[14+16*i] := 128.0*(charx+1);
		(*y*)
		chary := ((addend1baby.value[u]-1) div 8);
		vertices[3+16*i] := 64.0*(chary); 
		vertices[7+16*i] := 64.0*(chary); 
		vertices[11+16*i] := 64.0*(chary+1);
		vertices[15+16*i] := 64.0*(chary+1);
		u := u+1;
		i := i+1;
	end;
	u := 0;
	while (u <> addend2baby.digits) do begin 
		(*x*)
		vertices[0+16*i] := 128.0*(sumbaby.digits-u-1); 
		vertices[4+16*i] := 128.0*(sumbaby.digits-u); 
		vertices[8+16*i] := 128.0*(sumbaby.digits-u-1); 
		vertices[12+16*i] := 128.0*(sumbaby.digits-u); 
		(*y*)
		vertices[1+16*i] := 128; 
		vertices[5+16*i] := 128; 
		vertices[9+16*i] := 64; 
		vertices[13+16*i] := 64; 
		(*texture*)
		(*x*)
		charx := ((addend2baby.value[u]-1) mod 8);
		vertices[2+16*i] := 128*(charx);
		vertices[6+16*i] := 128.0*(charx+1); 
		vertices[10+16*i] := 128.0*(charx);
		vertices[14+16*i] := 128.0*(charx+1);
		(*y*)
		chary := ((addend2baby.value[u]-1) div 8);
		vertices[3+16*i] := 64.0*(chary); 
		vertices[7+16*i] := 64.0*(chary); 
		vertices[11+16*i] := 64.0*(chary+1);
		vertices[15+16*i] := 64.0*(chary+1);
		u := u+1;
		i := i+1;
	end;
	u := 0;
	while (u <> sumbaby.digits) do begin 
		(*x*)
		vertices[0+16*i] := 128.0*(sumbaby.digits-u-1); 
		vertices[4+16*i] := 128.0*(sumbaby.digits-u); 
		vertices[8+16*i] := 128.0*(sumbaby.digits-u-1); 
		vertices[12+16*i] := 128.0*(sumbaby.digits-u); 
		(*y*)
		vertices[1+16*i] := 64; 
		vertices[5+16*i] := 64; 
		vertices[9+16*i] := 0; 
		vertices[13+16*i] := 0; 
		(*texture*)
		(*x*)
		charx := ((sumbaby.value[u]-1) mod 8);
		vertices[2+16*i] := 128.0*(charx);
		vertices[6+16*i] := 128.0*(charx+1); 
		vertices[10+16*i] := 128.0*(charx);
		vertices[14+16*i] := 128.0*(charx+1);
		(*y*)
		chary := ((sumbaby.value[u]-1) div 8);
		vertices[3+16*i] := 512+64.0*(chary); 
		vertices[7+16*i] := 512+64.0*(chary); 
		vertices[11+16*i] := 512+64.0*(chary+1);
		vertices[15+16*i] := 512+64.0*(chary+1);
		u := u+1;
		i := i+1;
	end;
	for i := 0 to numofquads-1 do begin
		indices[0+6*i] := 0+4*i;
		indices[1+6*i] := 1+4*i;
		indices[2+6*i] := 2+4*i;
		indices[3+6*i] := 1+4*i;
		indices[4+6*i] := 2+4*i;
		indices[5+6*i] := 3+4*i;
	end;

	programHandle := Program_Create(vertexShaderFile, fragmentShaderFile);
	glUseProgram(programHandle);

	glGenVertexArrays(1, @VAO);
	glBindVertexArray(VAO);

	glGenBuffers(1, @quadVBO);
	glBindBuffer(GL_ARRAY_BUFFER, quadVBO);
	glBufferData(GL_ARRAY_BUFFER, SizeOf(single)*16*numofquads, Pointer(vertices), GL_STATIC_DRAW);

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 4 * SizeOf(Single) , PUint64(0));

	glEnableVertexAttribArray(1);
	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 4 * SizeOf(Single) , PUint64(2 * SizeOf(Single)));

	glGenBuffers(1, @quadEBO);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, quadEBO);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, SizeOf(Byte)*6*numofquads, Pointer(indices), GL_STATIC_DRAW);	

	textureHandle := Texture_Load('charmap.png');
	glUniform1i(glGetUniformLocation(programHandle, 'charmapTexture'), 0);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, textureHandle);

	glGenerateMipmap(GL_TEXTURE_2D);
 	
	new(sdlEvent);
	quit := false;
	while quit = false do begin
		while SDL_PollEvent(sdlEvent) = 1 do begin
			if sdlEvent^.key.keysym.sym = SDLK_ESCAPE then begin
				quit := true;
			end;
			if sdlEvent^.type_ = SDL_QUITEV then begin
				quit := true;
			end;
		end;

		glClearColor(0.0, 0.0, 0.0, 1.0);
		glClear(GL_COLOR_BUFFER_BIT);

		glUseProgram(programHandle);

		glUniform2fv(glGetUniformLocation(programHandle, 'resolution'), 1, resolution);

		glBindVertexArray(VAO);
		glDrawElements(GL_TRIANGLES, 6*numofquads, GL_UNSIGNED_BYTE, Pointer(0));

		SDL_GL_SwapWindow(sdlWindow);
	end;	

	glDeleteProgram(programHandle);
	glDeleteBuffers(1, @quadVBO);
	glDeleteBuffers(1, @quadEBO);
	glDeleteVertexArrays(1, @VAO);
	SDL_GL_DeleteContext(sdlGLContext);
	SDL_DestroyWindow(sdlWindow);
	SDL_Quit();
end.
