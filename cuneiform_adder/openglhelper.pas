unit openglhelper;
INTERFACE
uses
	Classes, SysUtils, SDL2, SDL2_image, GL, GLext, ImagingTypes, Imaging;
procedure scc(code : Integer);
function scp(point : PSDL_Window) : PSDL_Window;
function scp(point : TSDL_GLContext) : TSDL_GLContext;
function Program_Create(vertexShaderFile, fragmentShaderFile : String) : GLuint; 
function Texture_Load(imgsrc : String) : GLuint;
IMPLEMENTATION
procedure scc(code : Integer);
begin
	if (code < 0) then begin
		WriteLn('SDL ERROR: ', SDL_GetError());
		Halt(0);
	end;
end;
function scp(point : PSDL_Window) : PSDL_Window;
begin
	if (point = NIL) then begin
		WriteLn('SDL ERROR: ', SDL_GetError());
		Halt(0);
	end;
	scp := point;
end;
function scp(point : TSDL_GLContext) : TSDL_GLContext;
begin
	if (@point = NIL) then begin
		WriteLn('SDL ERROR: ', SDL_GetError());
		Halt(0);
	end;
	scp := point;
end;
function Program_Create(vertexShaderFile, fragmentShaderFile : String) : GLuint; 
var
	i : Integer;
	VertexShaderID : GLuint;
	FragmentShaderID : GLuint;
	ProgramID : GLuint;
	ShaderCode : TStringList;
	FragmentShaderCode : PGLchar;
	VertexShaderCode : PGLchar;
	compilationResult : GLint = GL_FALSE;
	InfoLogLength : GLint;
	ErrorMessageArray : array of GLChar;
begin
	VertexShaderID := glCreateShader(GL_VERTEX_SHADER);
	FragmentShaderID := glCreateShader(GL_FRAGMENT_SHADER);

	ShaderCode := TStringList.Create();
	ShaderCode.LoadFromFile(vertexShaderFile);
	VertexShaderCode := ShaderCode.GetText();
	if VertexShaderCode = NIL then Halt(0);
	ShaderCode.LoadFromFile(fragmentShaderFile);
	FragmentShaderCode := ShaderCode.GetText();
	if FragmentShaderCode = NIL then Halt(0);
	ShaderCode.Free();

	glShaderSource(VertexShaderID, 1, @VertexShaderCode, NIL);
	glCompileShader(VertexShaderID);

	glGetShaderiv(VertexShaderID, GL_COMPILE_STATUS, @compilationResult);
	glGetShaderiv(VertexShaderID, GL_INFO_LOG_LENGTH, @InfoLogLength);
	if compilationResult = GL_FALSE then begin
		WriteLn('ERROR');
		SetLength(ErrorMessageArray, InfoLogLength+1);
		glGetShaderInfoLog(VertexShaderID, InfoLogLength, NIL, @ErrorMessageArray[0]);
		for i := 0 to InfoLogLength do write(String(ErrorMessageArray[i]));
		WriteLn();
	end;

	glShaderSource(FragmentShaderID, 1, @FragmentShaderCode, NIL);
	glCompileShader(FragmentShaderID);

	glGetShaderiv(FragmentShaderID, GL_COMPILE_STATUS, @compilationResult);
	glGetShaderiv(FragmentShaderID, GL_INFO_LOG_LENGTH, @InfoLogLength);
	if compilationResult = GL_FALSE then begin
		WriteLn('ERROR');
		SetLength(ErrorMessageArray, InfoLogLength+1);
		glGetShaderInfoLog(FragmentShaderID, InfoLogLength, NIL, @ErrorMessageArray[0]);
		for i := 0 to InfoLogLength do write(String(ErrorMessageArray[i]));
		WriteLn();
	end;
	
	ProgramID := glCreateProgram();
	glAttachShader(ProgramID, VertexShaderID);
	glAttachShader(ProgramID, FragmentShaderID);
	glLinkProgram(ProgramID);

	glGetShaderiv(ProgramID, GL_LINK_STATUS, @compilationResult);
	glGetShaderiv(ProgramID, GL_INFO_LOG_LENGTH, @InfoLogLength);
	if compilationResult = GL_FALSE then begin
		WriteLn('ERROR');
		SetLength(ErrorMessageArray, InfoLogLength+1);
		glGetShaderInfoLog(ProgramID, InfoLogLength, NIL, @ErrorMessageArray[0]);
		for i := 0 to InfoLogLength do write(String(ErrorMessageArray[i]));
		WriteLn();
	end;

	glDetachShader(ProgramID, VertexShaderID);
	glDetachShader(ProgramID, FragmentShaderID);
	glDeleteShader(VertexShaderID);
	glDeleteShader(FragmentShaderID);
	StrDispose(VertexShaderCode);
	StrDispose(FragmentShaderCode);

	Program_Create := ProgramID;
end;
function Texture_Load(imgsrc : String) : GLuint;
var
	TextureID : GLuint; 
	imgload : TImageData;
	err : Boolean;
begin
	glGenTextures(1, @TextureID);
	glBindTexture(GL_TEXTURE_2D, TextureID);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	InitImage(imgload);
	err := LoadImageFromFile(imgsrc, imgload);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imgload.width, imgload.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imgload.bits);
	glGenerateMipmap(GL_TEXTURE_2D);

	Texture_Load := TextureID;
end;
end.
