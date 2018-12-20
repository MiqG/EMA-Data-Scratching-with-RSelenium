---
output: html_notebook
---
<style type="text/css">
body{ /* Normal */
        font-family: Cambria;
        font-size: 13pt;
      }
</style>

#**Data Scratching form the European Medicines Agency**

###[*Miquel Anglada Girotto*]{style="float:right"}
\
\
\
\
In this notebook, I use the package "RSelenium" to obtain the information published for each drug in the European Medicines Agency (EMA) webpage.

Before each chunk, I try to summarize what the code below will be doing. More detailed description can be found inline for those parts of the code that I found may be confusing.
\
\
##0. Pre-load R packages
\
These are the packages that will be needed to execute the rest fo the code.
```{r}
library(RSelenium)
library(stringr)
library(xlsx)
```

##1. Initialize RSelenium
\
This chunk starts the automated browser. The browser that will be used is your system's default browser.
```{r}
rD <- rsDriver()
remDr <- rD[["client"]]

```
\
\
##2. Obtain links for each drug
\
Here, I open **EMA's webpage** that lists all the drugs approved by the agency and get the link for each drug webpage.
```{r}
# Navigate to a list of all drugs

  remDr$navigate("https://www.ema.europa.eu/medicines/field_ema_web_categories%253Aname_field/Human/ema_group_types/ema_medicine")


# Define pages to look through

  page <- "https://www.ema.europa.eu/en/medicines/field_ema_web_categories%253Aname_field/Human/ema_group_types/ema_medicine?page=" #link to navigate through each page of the list.
  n <- as.character(round(1495/25)-1) #no. of pages to navigate, as.character() to allow pasting with the 'page' string.

  
# Loop through each page of the list and save links for each drug
  
  drug.webs <- {}
  for (i in 1:n){
    wp <- paste(page,as.character(i),sep="")
    remDr$navigate(wp)
    webElem <- remDr$findElements("css selector","[href]")
    css_links <- unlist(sapply(webElem,function(x){x$getElementAttribute("href")}))
    id <- str_detect(css_links,"EPAR/")
    drug.webs <- c(drug.webs,css_links[id])
  }

  
head(drug.webs)
```
\
\
##3. Use drug links to retrieve information from EMA's webpage for each drug
\
After creating a character vector called "**drug.webs**" containing all the drugs' links, I used it to extract the information from the tables: "Publication details" and "Product details".
```{r}
# Use drug links to retrieve drug info
  
  DB <- list()
  done <- {}
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
    not_done <- setdiff(drug.webs,done)
    
    
# Save in a variable
    
  drugsDB <- list(drug.webs,DB)
```
\
\
##4. Create Excel sheet to store data
\
Create a final table *.xlsx* to summarize and store the data obtained from EMA's webpage.
```{r}
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
  head(sheet)
  
# Save  
  
  your.path <- "" #INSERT PATH AND FILE NAME
  write.xlsx(sheet,file = your.path,row.names = F)
```
