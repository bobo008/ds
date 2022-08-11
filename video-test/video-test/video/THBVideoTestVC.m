//
//  THBVideoTestVC.m
//  video-test
//
//  Created by tanghongbo on 2022/8/11.
//

#import "THBVideoTestVC.h"
//
//precision highp float;
//
//#define TRAIL_MAX_COUNT 100
//#define PARTICLE_MAX_COUNT 100
//
//varying vec2 textureCoordinate;
//
//uniform float uAspect;
//
//uniform int trailCount;
//uniform vec2 trail[TRAIL_MAX_COUNT];
//uniform vec3 trailColor;
//uniform int particleCount;
//uniform vec3 particles[PARTICLE_MAX_COUNT];
//uniform vec3 colors[PARTICLE_MAX_COUNT];
//uniform float trailGlow;
//uniform float particleGlow;
//
//void main() {
//
//    vec2 st = textureCoordinate;
//    st.x *= uAspect;
//
//    float r = 0.0;
//    float g = 0.0;
//    float b = 0.0;
//
//    for (int i = 0; i < trailCount; i++) {
//        if (i < trailCount) {
//            vec2 trailPos = trail[i];
//
//            float value = float(i) / distance(st, trailPos.xy) * 0.0001 * trailGlow; // Multiplier may need to be adjusted if max trail count is tweaked.
//
//            r += trailColor.r * value;
//            g += trailColor.g * value;
//            b += trailColor.b * value;
//        }
//    }
//
//    float mult = 0.00005 * particleGlow;
//
//    for (int i = 0; i < particleCount; i++) {
//
//        vec3 particle = particles[i];
//        vec2 pos = particle.xy;
//        float mass = particle.z;
//        vec3 color = colors[i];
//
//        r += color.r / distance(st, pos) * mult * mass;
//        g += color.g / distance(st, pos) * mult * mass;
//        b += color.b / distance(st, pos) * mult * mass;
//    }
//
//    float a = max(r, max(g, b));
//    gl_FragColor = vec4(r, g , b , a);
//}
//
//
//attribute vec4 position;
//attribute vec4 inputTextureCoordinate;
//
//varying vec2 textureCoordinate;
//
//void main()
//{
//    gl_Position = position;
//    textureCoordinate = inputTextureCoordinate.xy;
//}



@interface THBVideoTestVC ()

@end

@implementation THBVideoTestVC

- (void)viewDidLoad {
    [super viewDidLoad];


}













- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
