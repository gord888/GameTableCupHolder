


include <roundedcube.scad>;



// Recommend at least 30 for printing.
$fn=30; //[10:Prototyping, 30:Printing, 50:Quality Print]


// Part
Part="slot"; // [top:Top Plate, bottom:Bottom Plate , slot:Slot Wedge, filler:Cup Holder Filler]


//  This is the overall depth between the edge of the cup holder, to the centre of the bolts.  20mm to your required length to compensate for slot placement and middle rounded corner cube.  So if i need 90mm to clear my table, then x=90+20=110.  The dice tray will adjust to 80% of the size. Note: param is [length, width]
LedgeSize=[110,95]; 

// This is the plate thickness.  
Thickness=15; 

// This is the cup holder size.  You can make the cup holder portion smaller or larger than the ledge size.  Note:  param is: [length, width]
CupHolderSize=[90,95]; 

// Cup holder diameter
CupDiameter=40; //[35:Small, 40:Medium, 45:Large] 

// This is how far away the bolt is from the edge.  I don't recommend changing this unless you have an awkward size that needs changing.
BoltHoleOffset=13;

// This bolt hole radius is setup for the recommended bolts.  You can adjust acording to your needs.
BoltHoleRadius=5.25;


// Text to put on the slot
SlotText="GORDOX";

// Text aligntment
TextAlign=([2,7.5, 49]);


// ---------------- MAIN -------------------

if(Part == "top")
{
    // Top Plate with Slots
    topPlateWithSlots(ledge=LedgeSize, cupHolderSize=CupHolderSize, cupSize=    CupDiameter, thickness=Thickness);
}

if(Part == "slot")
{
    // Wedge
    // call this to generate the wedge with the actual size
    translate([-30,10,0])
        plateWedge(ledge=LedgeSize, cupHolderSize=CupHolderSize, cupSize=CupDiameter, thickness=Thickness, text=SlotText);
}



if(Part == "bottom")
{
    // Bottom Plate
    translate([LedgeSize[0]-50,0,-Thickness - Thickness])
        bottomPlate(ledge=LedgeSize, cupHolderSize=CupHolderSize, cupSize=CupDiameter, thickness=Thickness);
}

if(Part == "filler")
{
    // cup Filler Plate
    translate([150,47,-50])
        cupFillerPlate(CupDiameter);
}

//------------------ MODULES ---------------------

module cupFillerPlate(cupDiameter)
{
    cylinder(h=1.6, r1=cupDiameter-0.5, r2=cupDiameter-0.5, center=true);
}


module bottomPlate(ledge, cupHolderSize, cupSize, thickness)
{
    // this just changes what would be the "ledge" part to a fixed x length of 10
    // which is the same as the rounded corner.  This allows us to "hull" around
    // it nicely with a rounded corner
    bottomPlateLedge=[50, ledge[1]];

    topPlateWithCupHole(bottomPlateLedge, cupHolderSize, cupSize, thickness, "z", true);

}

module wedge(width, height, thickness, text)
{
    difference(){
        hull(){
            
            // main
            translate([0,0,height *4]) roundedcube([thickness, width, 2], false, 1, "x");
                
            //translate([0,0,height *4])                cube([thickness, width, 2], false, 1);
            
            // taper down
            translate([0,(width - width*.70)/2,0]) roundedcube([thickness, width*.70, 1], false, 1, "x");        
        }

        // add text       
        translate(TextAlign)
        rotate([90,0,90])
        linear_extrude(height=5){
            #text(text=text, size=10, halign="left", valign="baseline", font="Arial Rounded MT Bold");
        }
    }
}

// makes it smaller
module plateWedge(ledge, cupHolderSize, cupSize, thickness, text)
{
    wedge(ledge[1] *.78 , thickness, 4.5, text );


}


module topPlateWithSlots(ledge, cupHolderSize, cupSize, thickness)
{
    // the slot should be the ledge size/2 with a wedge shape
    
    
    
    difference(){
        topPlateWithCupHole(ledge, cupHolderSize, cupSize, thickness);

        // make a wedge
        // adjust the wedge size for the hole cutout with a 1mm tolerance on all sides - 2 total
        // move the wedge the 10mm away from the edge.
        wedge_width = ledge[1]*.8;
        wedge_height = thickness;
        translate([10,(ledge[1] - wedge_width)/2,-thickness*1.75])
            wedge(wedge_width, wedge_height, 5);


        // cutout the dice holder
        translate([20 ,(ledge[1] - ledge[1]*.80)/2,thickness-5])
            roundedcube([ledge[0]*.70, ledge[1]*.80, 5], false, 1, "z");



    }
    
    
    
    
}


module topPlateWithCupHole(ledge, cupHolderSize, cupSize, thickness, corners="zmax", cupLedge=false)
{
    difference(){
        basePlate(ledge, cupHolderSize, cupSize, thickness, corners);

        // cup cutout
        if(cupLedge){
            union(){
                translate([ledge[0] + (cupHolderSize[0]/2) -5 ,ledge[1]/2,0])
                    cylinder(h=thickness, r1=cupSize-2, r2=cupSize-2, center=false);

                translate([ledge[0] + (cupHolderSize[0]/2) -5 ,ledge[1]/2,2])
                    cylinder(h=thickness, r1=cupSize, r2=cupSize, center=false);
            }
        }        
        else 
        {
            // the -5 is to compensate for the rounded cube
            translate([ledge[0] + (cupHolderSize[0]/2) -5 ,ledge[1]/2,-1])
                cylinder(h=thickness + 100, r1=cupSize, r2=cupSize, center=false);
            
        }

        // handle cutout
        translate([ledge[0] + (cupHolderSize[0]/2) - 20,ledge[1]/2,-2])
            cube([30,cupSize+500,thickness + 10]);
        
        // holes for bolts
        // these are a 13mm from the edge
        translate([ledge[0] ,BoltHoleOffset,thickness/2])
            cylinder(h=thickness+5, r1=BoltHoleRadius, r2=BoltHoleRadius, center=true);

        translate([ledge[0] ,ledge[1]-BoltHoleOffset,thickness/2])
            cylinder(h=thickness+5, r1=BoltHoleRadius, r2=BoltHoleRadius, center=true);


        translate([ledge[0]  + cupHolderSize[0] - BoltHoleOffset,BoltHoleOffset,thickness/2])
            cylinder(h=thickness+5, r1=BoltHoleRadius, r2=BoltHoleRadius, center=true);

        translate([ledge[0] + cupHolderSize[0] - BoltHoleOffset,ledge[1]-BoltHoleOffset,thickness/2])
            cylinder(h=thickness+5, r1=BoltHoleRadius, r2=BoltHoleRadius, center=true);


    }    
}

module basePlate(ledge, cupHolderSize, cupSize, thickness, corners="zmax")
{
    hull(){
        // table platform portion
        roundedcube([ledge[0], ledge[1], thickness], false, 5, corners);

        // cup holder
        translate([ledge[0],(ledge[1]-cupHolderSize[1])/2,0])
            roundedcube([cupHolderSize[0],cupHolderSize[1],thickness], false, 5, corners);
    }
}




