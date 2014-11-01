#include "Aluminum/Includes.hpp"

#include "Aluminum/Program.hpp"
#include "Aluminum/MeshBuffer.hpp"
#include "Aluminum/MeshData.hpp"
#include "Aluminum/Shapes.hpp"
#include "Aluminum/Camera.hpp"
#include "Aluminum/Utils.hpp"
#include "Aluminum/MeshUtils.hpp"
#include "Aluminum/FBO.hpp"
#include "Aluminum/Behavior.hpp"
#include "Aluminum/ResourceHandler.h"


using namespace aluminum;

class FBOExample : public RendererOSX {

public:
  
  ResourceHandler rh;
  
  Program textureProgram, phongProgram, programColor, shadowProgram;
  GLint posLoc = 0, normalLoc = 1, texCoordLoc = 2, colorLoc = 3;
  mat4 model, view, proj;
  MeshData mesh1, mesh2;
  MeshBuffer mb1, mb2;
  FBO fbo;
  MeshBuffer cubeMeshBuffer1, cubeMeshBuffer2, cubeMeshBuffer3;
  Texture texture;
  Behavior rotateBehavior;
    
    float zpos = -2.0;
    float angle = 0.0;
  
  vec3 l1_diffuse = vec3(0.0,1.0,0.0);
  vec3 l1_specular = vec3(1.0,1.0,1.0);
  
  vec3 l2_diffuse = vec3(0.0,0.0,1.0);
  vec3 l2_specular = vec3(1.0,1.0,1.0);
  
  
  void onCreate() {
    
    //rh.loadTexture(texture, "hubble.jpg");
      
      
    texture.wrapMode(GL_CLAMP_TO_EDGE);
    texture.minFilter(GL_NEAREST);
    texture.maxFilter(GL_NEAREST);
    
    //rh.loadProgram(textureProgram, "texture", posLoc, -1, texCoordLoc, -1);
    rh.loadProgram(phongProgram, "phong", posLoc, normalLoc, texCoordLoc, -1);
    //rh.loadProgram(programColor, "color", posLoc, normalLoc, -1, colorLoc);
      rh.loadProgram(shadowProgram, "shadow", posLoc, -1, -1, -1);
    
    MeshData md1;
    addCube(md1, true, 0.95);
    
    MeshData md2;
    addCube(md2, true, 0.5);
    
    MeshData md3;
    addCube(md3, 0.33); //this version makes normals, texcoords, and colors each side with a different default color
    
    cubeMeshBuffer1.init(md1, posLoc, normalLoc, texCoordLoc, -1);
    cubeMeshBuffer2.init(md2, posLoc, normalLoc, texCoordLoc, -1);
    
    cubeMeshBuffer3.init(md3, posLoc, normalLoc, -1, colorLoc);
    
    
    fbo.create(256, 256);
    
//    rotateBehavior = Behavior(now()).delay(1000).length(5000).range(vec3(M_PI, M_PI * 2, M_PI_2)).reversing(true).repeats(-1).sine();
//    
//    
//    proj = glm::perspective(glm::radians(60.0f), float(width)/float(height), 0.1f, 100.0f);
//    view = glm::lookAt(vec3(0.0,0.0,3), vec3(0,0,0), vec3(0,1,0) );
//    model = glm::mat4();
      
    
    
    glEnable(GL_DEPTH_TEST);
    glViewport(0, 0, width, height);
  }
  
  
//  void draw(mat4& model, MeshBuffer& mb, Texture& t, Program& p) {
//    
//    p.bind(); {
//      glUniformMatrix4fv(p.uniform("model"), 1, 0, ptr(model));
//      glUniformMatrix4fv(p.uniform("view"), 1, 0, ptr(view));
//      glUniformMatrix4fv(p.uniform("proj"), 1, 0, ptr(proj));
//      
//      t.bind(GL_TEXTURE0); {
//        
//        glUniform1i(p.uniform("tex0"), 0);
//        mb.draw();
//        
//      } t.unbind(GL_TEXTURE0);
//      
//    } p.unbind();
//  }
  
  
  void onFrame(){
      
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glClearColor(0.0,0.0,0.0,1.0);
      
      angle++;
      
      // Compute the MVP matrix from the light's point of view
       glm::mat4 depthProjectionMatrix = glm::ortho<float>(-10,10,-10,10,-10,20);

      
      glm::mat4 depthViewMatrix = glm::lookAt(vec3(-10.0,10.0,zpos), glm::vec3(0,0,0), glm::vec3(0,1,0));
      glm::mat4 depthModelMatrix = glm::mat4(1.0);
      glm::mat4 depthMVP = depthProjectionMatrix * depthViewMatrix * depthModelMatrix;
      
      model = mat4();
      
      model = glm::translate(model, vec3(0.0,0.0,0.0));
      //model = glm::rotate(angle, vec3(0.0,1.0,0.0));
      
//      shadowProgram.bind(); {
//          // Send our transformation to the currently bound shader,
//          // in the "MVP" uniform
//          glUniformMatrix4fv(shadowProgram.uniform("depthMVP"), 1, GL_FALSE, ptr(depthMVP));
//          glUniformMatrix4fv(shadowProgram.uniform("model"), 1, 0, ptr(model));
//          
//          cubeMeshBuffer1.draw();
//          
//          model = glm::translate(model, vec3(-7.0,0.0,0.0));
//          glUniformMatrix4fv(shadowProgram.uniform("model"), 1, 0, ptr(model));
//          cubeMeshBuffer2.draw();
//      }shadowProgram.unbind();
      
      phongProgram.bind(); {
          glUniformMatrix4fv(phongProgram.uniform("model"), 1, 0, ptr(model));
          glUniformMatrix4fv(phongProgram.uniform("view"), 1, 0, ptr(view));
          glUniformMatrix4fv(phongProgram.uniform("proj"), 1, 0, ptr(proj));
          
          //glUniform1i(phongProgram.uniform("tex0"), 0);
          
          cubeMeshBuffer1.draw();
          
          model = glm::translate(model, vec3(-7.0,0.0,0.0));
          glUniformMatrix4fv(phongProgram.uniform("model"), 1, 0, ptr(model));
          
          cubeMeshBuffer2.draw();
          
          
          
          
      }phongProgram.unbind();
    
    
    model = glm::mat4(1.0);
    
//    
//    vec3 totals = rotateBehavior.tick(now()).totals();
//    
//    model = glm::rotate(model, totals.x, vec3(1.0f,0.0f,0.0f));
//    model = glm::rotate(model, totals.y, vec3(0.0f,1.0f,0.0f));
//    model = glm::rotate(model, totals.z, vec3(0.0f,0.0f,1.0f));
//    
//
//    //draw cube 1 into an offscreen texture
//    fbo.bind(); {
//      glClearColor(0.1,0.1,0.1,1.0);
//      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//      
//      draw(model, cubeMeshBuffer1, texture, textureProgram);
//      
//    } fbo.unbind();
//    
//    
//    //draw cube 2 with the offscreen texture using phong shading
//    glViewport(0, 0, width, height);
//    glClearColor(0.0,0.0,0.0,1.0);
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//    
//    model = glm::mat4(1.0);
//    
//    model = glm::translate(model, vec3(1.0,0.0,0.0));
//    model = glm::rotate(model, totals.x, vec3(1.0f,0.0f,0.0f));
//    model = glm::rotate(model, totals.y, vec3(0.0f,1.0f,0.0f));
//    model = glm::rotate(model, totals.z, vec3(0.0f,0.0f,1.0f));
//    
//    draw(model, cubeMeshBuffer2, fbo.texture, phongProgram);
//    
//    
//    
//    //draw cube 3 - a colored cube
//    
//    model = mat4(1.0);
//    model = glm::translate(model, vec3(-1.0,0.0,0.0));
//    
//    model = glm::rotate(model, -totals.x, vec3(1.0f,0.0f,0.0f));
//    model = glm::rotate(model, -totals.y, vec3(0.0f,1.0f,0.0f));
//    model = glm::rotate(model, -totals.z, vec3(0.0f,0.0f,1.0f));
//    
//    programColor.bind(); {
//      glUniformMatrix4fv(programColor.uniform("model"), 1, 0, ptr(model));
//      glUniformMatrix4fv(programColor.uniform("view"), 1, 0, ptr(view));
//      glUniformMatrix4fv(programColor.uniform("proj"), 1, 0, ptr(proj));
//      
//      cubeMeshBuffer3.draw();
//      
//    } programColor.unbind();
    
  }

    
    virtual void keyDown(char key) {
        
        switch(key) {
            case kVK_ANSI_F :
                zpos += 1.0;
                break;
            case kVK_ANSI_V :
                zpos -= 1.0;
                break;
           
        }
    }

  
};

int main(){
  return FBOExample().start("aluminum::FBOExample", 100, 100, 400, 300);
}
