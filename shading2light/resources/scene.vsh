#version 150
// Input vertex data, different for all executions of this shader.
//layout(location = 0)
in vec4 vertexPosition, vertexNormal;

// Values that stay constant for the whole mesh.
uniform mat4 DepthBiasMVP;
uniform mat4 model, view, proj;
uniform vec4 l1_position;

out vec4 ShadowCoord;
out vec3 N,L1,V;

void main(){
    // Output position of the vertex, in clip space : MVP * position
    mat4 MVP = proj * view * model;
    
    N = normalize(mat3(view) * mat3(model) * vertexNormal.xyz);
    vec4 L1_cam = view * l1_position;
    
    vec4 position = proj * view * model * vertexPosition;
    V = normalize(-(position.xyz));
    L1 = vec3(normalize(L1_cam - position).xyz);
    
    gl_Position = MVP * vec4(vertexPosition);
    
    // Same, but with the light's view matrix
    ShadowCoord = DepthBiasMVP * vec4(vertexPosition);
}