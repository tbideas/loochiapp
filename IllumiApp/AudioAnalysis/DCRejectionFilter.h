//
//  DCRejectionFilter.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 8/31/12.
//  Copy&Paste from Apple's aurioTouch2 example aurio_helper.h
//  See Apple source file for full disclaimer.
//

#ifndef Illumi_DCRejectionFilter_h
#define Illumi_DCRejectionFilter_h

class DCRejectionFilter
{
public:
	DCRejectionFilter(Float32 poleDist = DCRejectionFilter::kDefaultPoleDist);
    
	void InplaceFilter(Float32* ioData, UInt32 numFrames);
	void Reset();
    
protected:
	
	// State variables
	Float32 mY1;
	Float32 mX1;
	
	static const Float32 kDefaultPoleDist;
};


#endif
