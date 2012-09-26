//
//  DCRejectionFilter.mm
//  Illumi
//
//  Created by Thomas SARLANDIE on 8/31/12.
//
//

#include "DCRejectionFilter.h"

const Float32 DCRejectionFilter::kDefaultPoleDist = 0.975f;

DCRejectionFilter::DCRejectionFilter(Float32 poleDist)
{
	Reset();
}

void DCRejectionFilter::Reset()
{
	mY1 = mX1 = 0;
}

void DCRejectionFilter::InplaceFilter(Float32* ioData, UInt32 numFrames)
{
	for (UInt32 i=0; i < numFrames; i++)
	{
        Float32 xCurr = ioData[i];
		ioData[i] = ioData[i] - mX1 + (kDefaultPoleDist * mY1);
        mX1 = xCurr;
        mY1 = ioData[i];
	}
}
