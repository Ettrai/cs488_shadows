#include "Aluminum/Includes.hpp"

#include "Aluminum/Program.hpp"
#include "Aluminum/MeshBuffer.hpp"
#include "Aluminum/MeshData.hpp"
#include "Aluminum/Shapes.hpp"
#include "Aluminum/Camera.hpp"
#include "Aluminum/Utils.hpp"
#include "Aluminum/MeshUtils.hpp"
#include "Aluminum/ResourceHandler.h"
#include "objload.h"
#include "Aluminum/FBO.hpp"

using namespace aluminum;

class Lighting : public RendererOSX {
public:
  
  ResourceHandler rh;

  Camera camera;
  Program program, shadowProgram, sceneProgram;
  GLint posLoc = 0, normalLoc = 1;
  mat4 model1, model2, model3, lightModel1, lightModel2;
    mat4 objModel;
  MeshData mesh1, mesh2, mesh3, lightMesh;
  MeshBuffer mb1, mb2, mb3, lmb1, lmb2;
    
    MeshData meshObject;
    MeshBuffer mbObject;
    
    Texture shadowTexture;
    FBO shadowFbo;
    
    float threshold = 0.7;
  
  
  vec3 ambient = vec3(1.0,0.1,0.1);
  
//  vec3 l1_diffuse = vec3(0.2,0.7,0.9);
    vec3 l1_diffuse = vec3(0.1,0.1,0.1);
  vec3 l1_specular = vec3(0.1,0.1,0.1);
  
//  vec3 l2_diffuse = vec3(0.0,0.0,1.0);
//  vec3 l2_specular = vec3(1.0,1.0,1.0);
    
    float lx = 2.0;
    float ly = 5.0;
    float lz = -5.0;
  
  
    void loadObjIntoMesh(MeshData &modelMesh, const std::string& name, float scalar) {
        
        
        
        obj::Model m = obj::loadModelFromFile(rh.pathToResource(name));
        
        
        
        for(std::map<std::string, std::vector<unsigned short> >::const_iterator g = m.faces.begin(); g != m.faces.end(); ++g){
            
            std::cout << g->first << "\n" ;
            
            
            
            cout << "num indicies = " << g->second.size() << "\n";
            
            for (int i = 0 ; i < g->second.size() ; i++) {
                
                
                
                modelMesh.index(g->second[i]);
                
                //cout << g->second[i] << " ";
                
            }
            
            //cout << "\n";
            
        }
        
        
        
        
        
        cout << "vertex size = " << m.vertex.size() / 3 << "\n";
        
        cout << "normal size = " << m.normal.size() / 3 << "\n";
        
        
        
        for (int i = 0; i < m.vertex.size(); i+=3) {
            
            vec3 pos = vec3(m.vertex[i], m.vertex[i+1], m.vertex[i+2]);
            
            pos *= scalar;
            
            modelMesh.vertex(pos);
            
        }
        
        
        
        for (int i = 0; i < m.texCoord.size(); i+=2) {
            
            //	 modelMesh.texCoord(m.texCoord[i], m.texCoord[i+1]);
            
        }
        
        
        
        for (int i = 0; i < m.normal.size(); i+=3) {
            
            modelMesh.normal(m.normal[i], m.normal[i+1], m.normal[i+2]);
            
        }
        
        
        
    }
  
  
  void onCreate() {
    
    rh.loadProgram(program, "phong", posLoc, normalLoc, -1, -1);
    rh.loadProgram(shadowProgram, "shadow", posLoc, normalLoc, -1, -1);
      rh.loadProgram(sceneProgram, "scene", posLoc, normalLoc, -1, -1);
      
      loadObjIntoMesh(meshObject, "room.obj", 2.0);
    
    camera = Camera(glm::radians(60.0), (float)width/(float)height, 0.01, 100.0).translate(vec3(-4.0,0.0,-20.0));
      
      shadowTexture.wrapMode(GL_CLAMP_TO_EDGE);
      shadowTexture.minFilter(GL_NEAREST);
      shadowTexture.maxFilter(GL_NEAREST);
      
      //shadowFbo.create(256,256);
      shadowFbo.create(400,300);
      
    

    addSphere(mesh1, 2.0, 100, 100);
    addSphere(mesh2, 1.0, 100, 100);
//    addSphere(mesh3, 1.5, 100, 100);
    addSphere(lightMesh, 0.3, 10, 10);
    
    mb1.init(mesh1, posLoc, normalLoc, -1, -1);
    mb2.init(mesh2, posLoc, normalLoc, -1, -1);
    //mb3.init(mesh3, posLoc, normalLoc, -1, -1);
    lmb1.init(lightMesh, posLoc, normalLoc, -1, -1);
    //lmb2.init(lightMesh, posLoc, normalLoc, -1, -1);
      
      mbObject.init(meshObject, posLoc, normalLoc, -1, -1);
    
    model1 = glm::translate(mat4(), vec3(0,2,0));
    model2 = glm::translate(mat4(), vec3(5,2,0));
    //model3 = glm::translate(mat4(), vec3(0,0,-15));
      
      objModel = glm::translate(mat4(), vec3(0.0,0.0,0.0));
      objModel = glm::rotate(objModel, (3.14f/2.0f), vec3(0.0,1.0,0.0));
    
    
    
    camera.printCameraInfo();
    
    glEnable(GL_DEPTH_TEST);
  }
  /*
  int dir1 = 1;
  float pos1 = 0.0f;
 
  int dir2 = 1;
  float pos2 = 0.0f;
  */
  void draw(mat4 proj, mat4 view) {
    
    /* update light positions */
    /*
    pos1 += 0.2f * dir1;
    if (pos1 > 15.0 || pos1 < -15.0) {
      dir1 *= -1;
    }
    */
      vec4 l1_position ;
//    pos2 += 0.3f * dir2;
//    if (pos2 > 15.0 || pos2 < -15.0) {
//      dir2 *= -1;
//    }
//    vec4 l2_position = vec4(pos2, 0.0, 5.0, 1.0);
   
//    l1_position = vec4(pos1,5.0,1.0,1.0);
      l1_position = vec4(lx,ly,lz,1.0);
//    l2_position = vec4(0.0,pos2,-1.0,1.0);
    
    lightModel1 = glm::translate(mat4(), vec3(l1_position));
//    lightModel2 = glm::translate(mat4(), vec3(l2_position));
    
    /* bind our Phong lighting shader */
      
      
    
    program.bind(); {
      glUniformMatrix4fv(program.uniform("view"), 1, 0, ptr(view));
      glUniformMatrix4fv(program.uniform("proj"), 1, 0, ptr(proj));
    
      glUniform3fv(program.uniform("ambient"), 1, ptr(ambient));
      
      glUniform4fv(program.uniform("l1_position"), 1, ptr(l1_position));
      glUniform3fv(program.uniform("l1_diffuse"), 1, ptr(l1_diffuse));
      glUniform3fv(program.uniform("l1_specular"), 1, ptr(l1_specular));
        
        glUniform1f(program.uniform("threshold"), threshold);
  
      
//      glUniform4fv(program.uniform("l2_position"), 1, ptr(l2_position));
//      glUniform3fv(program.uniform("l2_diffuse"), 1, ptr(l2_diffuse));
//      glUniform3fv(program.uniform("l2_specular"), 1, ptr(l2_specular));
      
    /* draw the object*/
        glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(objModel));
        mbObject.draw();
        
        
        
        /* Draw the first sphere */
      glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model1));
      mb1.draw();
   
      /* Draw the second sphere */
      glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model2));
      mb2.draw();
    
      /* Draw the third sphere */
      glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(model3));
      mb3.draw();
   
      
      /* turn off the diffuse and speculars when drawing the positions of the lights */
      glUniform3fv(program.uniform("l1_diffuse"), 1, ptr(vec3(0.0)));
      glUniform3fv(program.uniform("l1_specular"), 1, ptr(vec3(0.0)));
      
//      glUniform3fv(program.uniform("l2_diffuse"), 1, ptr(vec3(0.0)));
//      glUniform3fv(program.uniform("l2_specular"), 1, ptr(vec3(0.0)));
      
      /* draw light 1 */
      glUniform3fv(program.uniform("ambient"), 1, ptr(l1_diffuse));
      glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(lightModel1));
      lmb1.draw();
        

      
      /* draw light 2 */
//      glUniform3fv(program.uniform("ambient"), 1, ptr(l2_diffuse));
//      glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(lightModel2));
//      lmb2.draw();
      
      
      
    } program.unbind();
    
  }
  
    void drawShadow(mat4 proj,mat4 view) {
        

        vec3 l1_position = vec3(lx,ly,lz);
        lightModel1 = glm::translate(mat4(), vec3(l1_position));
        
        // Compute the MVP matrix from the light's point of view
        glm::mat4 depthProjectionMatrix = glm::ortho<float>(-10,10,-10,10,-10,20);
        
        
        glm::mat4 depthViewMatrix = glm::lookAt(l1_position, glm::vec3(0,0,0), glm::vec3(0,1,0));
        glm::mat4 depthModelMatrix = glm::mat4(1.0);
        glm::mat4 depthMVP = depthProjectionMatrix * depthViewMatrix * depthModelMatrix;
        
        
        shadowFbo.bind(); {
            glViewport(0, 0, shadowFbo.width, shadowFbo.height);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
                
              shadowProgram.bind(); {
                  // Send our transformation to the currently bound shader,
                  // in the "MVP" uniform
                  glUniformMatrix4fv(shadowProgram.uniform("depthMVP"), 1, GL_FALSE, ptr(depthMVP));
                  glUniformMatrix4fv(shadowProgram.uniform("model"), 1, 0, ptr(model1));
        
                  //mb1.draw();
                  
                  glUniformMatrix4fv(shadowProgram.uniform("model"), 1, 0, ptr(model2));
                  
                  mb2.draw();
        
                  glUniformMatrix4fv(shadowProgram.uniform("model"), 1, 0, ptr(objModel));
                  
                  mbObject.draw();
                  
                  /* draw light 1 */
                  glUniform3fv(program.uniform("ambient"), 1, ptr(ambient));
                  glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(lightModel1));
                  //lmb1.draw();
              }shadowProgram.unbind();
        }shadowFbo.unbind();
        
        
        glm::mat4 biasMatrix(
                             0.5, 0.0, 0.0, 0.0,
                             0.0, 0.5, 0.0, 0.0,
                             0.0, 0.0, 0.5, 0.0,
                             0.5, 0.5, 0.5, 1.0
                             );
        glm::mat4 depthBiasMVP = biasMatrix*depthMVP;
        
        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        //glClearColor(1.0, 1.0, 1.0, 1.0);
        
        sceneProgram.bind(); {
            
            glUniformMatrix4fv(sceneProgram.uniform("depthBiasMVP"), 1, 0, ptr(depthBiasMVP));
            glUniformMatrix4fv(sceneProgram.uniform("view"), 1, 0, ptr(view));
            glUniformMatrix4fv(sceneProgram.uniform("proj"), 1, 0, ptr(proj));
            
            glUniform3fv(sceneProgram.uniform("ambient"), 1, ptr(ambient));
            
            glUniform3fv(sceneProgram.uniform("l1_diffuse"), 1, ptr(l1_diffuse));
            glUniform3fv(sceneProgram.uniform("l1_specular"), 1, ptr(l1_specular));
            glUniform3fv(sceneProgram.uniform("l1_position"), 1, ptr(l1_position));
            
            
            shadowFbo.texture.bind(GL_TEXTURE0); {
                glUniform1i(sceneProgram.uniform("shadowMap"), 0);
                
                glUniformMatrix4fv(sceneProgram.uniform("model"), 1, 0, ptr(model1));
                mb1.draw();
                
                glUniformMatrix4fv(sceneProgram.uniform("model"), 1, 0, ptr(model2));
                
                mb2.draw();
                
                glUniformMatrix4fv(sceneProgram.uniform("model"), 1, 0, ptr(objModel));
                
                mbObject.draw();
                
                /* draw light 1 */
                glUniform3fv(program.uniform("ambient"), 1, ptr(l1_diffuse));
                glUniformMatrix4fv(program.uniform("model"), 1, 0, ptr(lightModel1));
                lmb1.draw();
            }shadowFbo.texture.unbind(GL_TEXTURE0);
            
            

            
            
        }sceneProgram.unbind();
    
    }
    
    
  void onFrame(){
    
    if (camera.isTransformed) { //i.e. if you've pressed any of the keys to move or rotate the camera around
      camera.transform();
    }
    
    
    glViewport(0, 0, width, height); {
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      //draw(camera.projection, camera.view);
        drawShadow(camera.projection,camera.view);
        
    }
    
  }
  
  
    virtual void keyDown(char key) {
        
        
        
        switch(key) {
                
            case kVK_Space :
                
                camera.resetVectors();
                lx = 2.0;
                ly = 5.0;
                lz = 0.0;
                cout << "reset!" << endl;
                
                break;
                
            case kVK_ANSI_1:
                lx += 0.2;
                break;
            case kVK_ANSI_2:
                lx -= 0.2;
                break;
            case kVK_ANSI_3:
                ly += 0.2;
                break;
            case kVK_ANSI_4:
                ly -= 0.2;
                break;
            case kVK_ANSI_5:
                lz += 0.2;
                break;
            case kVK_ANSI_6:
                lz -= 0.2;
                break;
                
                
            case kVK_ANSI_J :
                
                camera.rotateY(glm::radians(2.));
                
                break;
                
                
                
            case kVK_ANSI_L :
                
                camera.rotateY(glm::radians(-2.));
                
                break;
                
                
                
            case kVK_ANSI_I :
                
                camera.rotateX(glm::radians(2.));
                
                break;
                
                
                
            case kVK_ANSI_K :
                
                camera.rotateX(glm::radians(-2.));
                
                break;
                
                
                
            case kVK_ANSI_U :
                
                camera.rotateZ(glm::radians(2.));
                
                break;
                
                
                
            case kVK_ANSI_M :
                
                camera.rotateZ(glm::radians(-2.));
                
                break;
                
                
                
            case kVK_ANSI_S :
                
                camera.translateZ(-0.5);
                
                break;
                
                
                
            case kVK_ANSI_W :
                
                camera.translateZ(0.5);
                
                break;
                
                
                
            case kVK_ANSI_A :
                
                camera.translateX(0.5);
                
                break;
                
                
                
            case kVK_ANSI_D :
                
                camera.translateX(-0.5);
                
                break;
                
                
                
            case kVK_ANSI_Z :
                
                camera.translateY(0.5);
                
                break;
                
                
                
            case kVK_ANSI_Q:
                
                camera.translateY(-0.5);
                
                break;
                
            case kVK_ANSI_T:
                threshold += 0.1;
                if(threshold >= 1.0){
                    threshold = 1.0;
                }
                break;
            case kVK_ANSI_G:
                threshold -= 0.1;
                if(threshold <= 0.0){
                    threshold = 0.0;
                }
                break;

                
                
                
                
                
                
                
        }
        
    }
};

int main(){ 
  return Lighting().start("aluminum::Lighting", 100, 100, 400, 300);
    
}
