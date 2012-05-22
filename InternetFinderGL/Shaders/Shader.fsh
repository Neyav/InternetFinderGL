//
//  Shader.fsh
//  InternetFinderGL
//
//  Created by Chris Laverdure on 12-05-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
