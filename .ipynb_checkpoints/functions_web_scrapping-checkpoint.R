initRSelenium = function(){
    ##########################
    # Start automated browser.
    ##########################
    
    rD <- rsDriver()
    remDr <- rD[["client"]]
}

getURLs = function(page,n){
    ##################################################################
    # Loop through each page of the list and save links for each drug
    ##################################################################
    
    # init vector
    drug.webs <- {}

    for (i in 1:n){ 
        # prepare new url
        wp <- paste(page,as.character(i),sep="")

        # go to url
        remDr$navigate(wp)

        # find elements
        webElem <- remDr$findElements("css selector","[href]")

        # extract drug links  
        css_links <- unlist(sapply(webElem,function(x){
            
                # navigate through XML
                x$getElementAttribute("href")
            
                }))
        
        # find id
        id <- str_detect(css_links,"EPAR/")
        # save drug link
        drug.webs <- c(drug.webs,css_links[id])}
    
        return(drug.webs)
}

getDrugInfo = function(drug.webs){
    ########################################################################
    # Obtain information from datasheet from each drug.
    ########################################################################
    # Use drug links to retrieve drug info
    
    DB <- list()
    done <- {}
    not_done <- setdiff(drug.webs,done)
    nerr <- 0
    it <- 0
    
    # Navigate to each drug's page, extract information of "Publication details" and "Product details", and store it:
  
    for (j in not_done){
        it <- it+1
        remDr$navigate(j)
        d <- remDr$findElements("css selector",".ecl-u-fs-m") #Elements to "find" were defined exploring the webpage in "Inspect" mode.
        css_text <- unlist(sapply(d,function(x){x$getElementText()}))
        css_text_clean <- css_text[!css_text %in% c("","Publication details","Product details")]
        drug_name <- gsub(".*(EPAR/)","",j)
      
        if ((length(css_text_clean)/2)%%1==0){
              coln <- css_text_clean[seq(1,length(css_text_clean)-1,2)]
              data <- css_text_clean[seq(2,length(css_text_clean),2)]
              DB[[drug_name]] <- list(coln,data)
        }else{
              #Record errors in reading tables from webpage
              DB[[drug_name]] <- css_text_clean
              nerr <- nerr+1
        }
    
        #Check performance
        done <- c(done,j)
        print(paste("There have been",nerr,"errors."))
        print(paste(it,"/",length(drug.webs)))
    }
    
    
    
    # Save in a variable
    drugsDB <- list(drug.webs,DB,nerr,it,not_done)
    return(drugsDB) 
    
}

processTable(drugsDB) = function(){
    
      #  Define variables:
      DB <- drugsDB[[2]] #retrieve DB variable containing all the information for each drug
      fields <- unlist(sapply(DB,function(x){x[[1]]})) #get all the fields catched
      reps <- sapply(unique(fields),function(x){sum(str_count(fields,x))}) #Count how many times each field appears
      fields_clean <- unique(fields)[reps>3 | reps<1] #save only unique fields


    # Generate table placing each value to their corresponding field

      table <- list()
      for (k in fields_clean){
        f <- {}
        for (r in 1:length(DB)){
          idx <- which(DB[[r]][[1]] %in% k)
          if(length(idx)==1){
            f <- c(f,DB[[r]][[2]][idx])
          }else if(length(idx)==0){
            f <- c(f,"-")  
          }else{
            f <- c(f,"ERROR")  
          }
        }
        table[[k]] <- f
      }

      sheet <- data.frame(table)

  return(sheet)
}


saveTable = function(df,your.path){
    # Save
    write.csv(df,file = your.path,row.names = F)
} 
