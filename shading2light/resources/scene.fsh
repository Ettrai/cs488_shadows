#version 150
// Ouput data
//layout(location = 0)
out vec3 color;
float spec_intensity = 32.0;

uniform vec3 ambient;
uniform vec3 l1_diffuse, l1_specular;
uniform sampler2D shadowMap;

in vec3 N,L1,V;
in vec4 ShadowCoord;

void main(){
    vec3 LightColor = vec3(0.2,0.2,0.2);
    
    float cosTheta = clamp(dot(N,L1),0.0,1.0);
    vec3 R = normalize(reflect(-L1,N));
    float cosAlpha = clamp(dot(V,R),0.0,1.0);
    
    float visibility = 1.0;
    if ( texture( shadowMap, ShadowCoord.xy ).z < ShadowCoord.z){
        visibility = 0.5;
    }
    
    color =
    // Ambient : simulates indirect lighting
    ambient +
    // Diffuse : "color" of the object
    visibility * l1_diffuse * LightColor * spec_intensity * cosTheta+
    // Specular : reflective highlight, like a mirror
    visibility * l1_specular * LightColor * spec_intensity * pow(cosAlpha,5);
    
    //color = vec3(visibility,0.0,0.0);
    //color = vec3(0.5,0.0,0.0);
    
}