/* _______________________________________________________________________________________________________________
   Name:		COF_FileVersion.cls
   Description: Wrapper Class for File ContentVersion
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Mar 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
public class COF_FileVersion {
	
	public Boolean selectFlag			{get; set;}
	public ContentVersion fileVersion	{get; set;}
	
	public COF_FileVersion(Boolean sflag, ContentVersion cv) {
		this.selectFlag = sflag;
		this.fileVersion = cv;
	}
    
}