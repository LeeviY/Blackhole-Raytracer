 #version 430
layout(local_size_x = 1, local_size_y = 1) in;
layout(rgba32f, binding = 0) uniform image2D imgOutput;
layout(binding = 0) uniform sampler2D bg;


void main() {
	// base pixel colour for image
	vec4 pixel = vec4(0.0f, 0.0f, 0.0f, 1.0f);
	// get index in global work group i.e x,y position
	ivec2 pixelCoords = ivec2(gl_GlobalInvocationID.xy);

	float maxX = 10.0f;
	float maxY = 10.0f;
	float maxXY = maxX + maxY;

	ivec2 dims = imageSize(imgOutput); // fetch image dimensions
	float x = (float(pixelCoords.x * 2 - dims.x) / dims.x);
	float y = (float(pixelCoords.y * 2 - dims.y) / dims.y);
	vec3 rayOrigin = vec3(x * maxX, y * maxY, 0.0f);
	vec3 rayDir = vec3(0.0f, 0.0f, -1.0f); // ortho

	vec3 sphereCenter = vec3(0.0f, 0.0f, -10.0f);
	float sphereRadius = 1.0f;

	float Rg = 1;	

	float dt = 0.01;

	vec3 rayPos = rayOrigin;

	for (int i = 0;i < 20000;i++)
	{
		rayPos += rayDir / 10;
		float r = length(rayPos - sphereCenter);

		vec3 F = (1 / pow(r, 2)) * normalize(rayPos);
		//vec3 F = (-10 / pow(r, 3)) * rayPos;
		rayDir += normalize(F) * dt;
		rayPos += normalize(rayDir) * dt;

		if ((pow(rayPos.x - sphereCenter.x, 2) + pow(rayPos.y - sphereCenter.y, 2)
			+ pow(rayPos.z - sphereCenter.z, 2)) < (sphereRadius * sphereRadius))
		{
			pixel = vec4(0.0f, 1.0f, 0.0f, 1.0f);
			//pixel = vec4(0.0f, 0.0f, 0.0f, 1.0f);
			break;
		}
		else if (rayPos.z < -20.0f)
		{
			vec2 pixelCoord = rayPos.xy/maxXY+0.5;
			pixel = texture2D(bg, pixelCoord);
			break;
		}
		else if (rayPos.z > 10.0f)
		{
			//pixel = vec4(1.0f, 0.0f, 1.0f, 1.0f);
			pixel = vec4(0.0f, 0.0f, 0.0f, 0.0f);
			break;
		}
		else if (rayPos.x < -maxX*2 || rayPos.x > maxX*2)
		{
			pixel = vec4(1.0f, 1.0f, 0.0f, 1.0f);
			break;
		}
		else if (rayPos.y < -maxY*2 || rayPos.y > maxY*2)
		{
			pixel = vec4(0.0f, 0.0f, 1.0f, 1.0f);
			break;
		}
	}
	// output to a specific pixel in the image
	imageStore(imgOutput, pixelCoords, pixel);
}