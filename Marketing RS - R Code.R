#import libraries
library(stringr)
library(data.table)
library(readr)
library(sqldf)
library(dplyr)
library(igraph)
library(recommenderlab)
library(BBmisc)

#Set the directory
getwd()
setwd()
# setwd('C:/Users/14702/OneDrive/Desktop/Emory/Macketing Analysis/Project 2 - Recommender System')

#import data files
products <- read_csv("C:/Users/banva/Downloads/product_table.csv")
transactions <- read_csv("C:/Users/banva/Downloads/transaction_table.csv")


############################################# data preparation #############################################

#Preliminary Exploratory Analysis on products data
length(unique(products$prod_id)) #10767 products, each row is a product
length(unique(products$category_desc)) #419 categories

#we don't want PRIVATE LABEL brans. Filter them out
products_noprivate =products[products$brand_desc != "PRIVATE LABEL",]

#We want only FINE WAFERS category and (Oreo and chips Ahoy brand in Mendelez). But use OR here 
final_products = products_noprivate[products_noprivate$category_desc_eng == "FINE WAFERS" | 
                                      (products_noprivate$brand_desc == "OREO" | products_noprivate$brand_desc =="CHIPS AHOY"), ]

#our final_products has 220 products now which has all the products in Fine wafer category and also OREO AND AHOY CHIPS prodcuts

#data prep
data = merge(transactions, final_products, by='prod_id', all.y=TRUE, all.x = FALSE)

# convert the tran_dt column into the date format
data$tran_dt = as.Date(data$tran_dt)

# create a new column for transaction id
data$new_id<-paste(as.character(data$tran_dt),as.character(data$cust_id),as.character(data$prod_id),data$store_id,sep='-')

# drop the old transaction id column
data$tran_id <- NULL

#Sanity Check
unique(data$category_desc_eng) #"FINE WAFERS"     "FROZEN DESSERTS" categories
unique(data$brand_desc) #we have oreo and ahoy chips and 33 more because we are including everything in Fine wafers so..
data%>% group_by(new_id)%>% count() #yes, all unique ids. 373299

#Find the cost when profit margin is 5%. we are assuming 5% is the profit margin.
data$cost =data$tran_prod_sale_amt*0.95

data=as.data.table(data)
class(data)

# create columns for discount percentage, weekdays, and month
data[,discount_rate:= abs(tran_prod_discount_amt)/tran_prod_sale_amt][,weekdays := weekdays(data$tran_dt)][,months := month(data$tran_dt)]

# create columns for monthly spending, monthly frequency, weekday spending, discount rate, types of products on discount, 
# discount frequency, product types, total spending, total frequency per customer
data[,month_spending := sum(tran_prod_paid_amt), by=.(months,cust_id)]
data[,month_freq := uniqueN(tran_dt), by=.(months,cust_id)]
data[,weekday_spending := sum(tran_prod_paid_amt), by=.(weekdays,cust_id)]
data[,discount_rate := sum(abs(tran_prod_discount_amt))/sum(tran_prod_sale_amt),by=cust_id]
data[,discount_count := sum(tran_prod_discount_amt!= 0), by=cust_id]
data[,discount_freq := discount_count/.N, by=cust_id]
data[,product_types := uniqueN(prod_id), by=cust_id]
data[,total_spending := sum(tran_prod_paid_amt),by=cust_id]
data[,total_freq:= uniqueN(tran_dt)/(365*2),by=cust_id]
data[,total_freq:= uniqueN(tran_dt)/(365*2),by=cust_id]

# write out the customer files
write.csv(data, file = "data.csv",row.names=TRUE)

#==========================================================================================



############################################# RS Modeling #############################################

# part1 - targeted customers and products

# get all the unique customers and products
customer = unique(data$cust_id)
product = unique(data$brand_desc)

# get the matrix of customer buying product with certain amount
cp_matrix = as(table(data$cust_id, data$brand_desc) ,"matrix")
# replace 0 with NA
cp_matrix[which(cp_matrix==0)] = NA
cp_dt = data.frame(cp_matrix)
customer = rownames(cp_dt)
# get a normalized matrix for modeling
cp_nmlz_matrix<-as(normalize(cp_dt),"matrix")

# transform the matrix into "realRatingMatrix"
rrm<- as(as(cp_nmlz_matrix, "matrix"), "realRatingMatrix")
rec.model = Recommender(rrm, method = "IBCF")
rec = predict(rec.model, rrm, type = "ratings")
# show outcomes 
reclist = as( rec, "list") 

# to choose if use customer based CF or item based CF, we split matrix and use train and test data to obtain the accuracy
# split matrix
e <- evaluationScheme(rrm, method = "split", train = 0.9, given = 1, goodRating = 0)
e
# customer based CF
r1 <- Recommender(getData(e , "train") , "UBCF") 
p1 <- predict(r1 , getData(e , "known") , type = "ratings") 
# item based CF
r2 <- Recommender(getData(e , "train") , "IBCF") 
p2 <- predict(r2 , getData(e , "known") , type = "ratings")
## calculate model accuracy 
c1 <- calcPredictionAccuracy(p1, getData(e , "unknown"))
c2 <- calcPredictionAccuracy(p2, getData(e , "unknown"))
error <- rbind(c1, c2) 
rownames(error) <- c("UBCF", "IBCF")
# item based CF perform better, decide to use it
error

# IBCF with TOP-5 recommender model
rec.model = Recommender(rrm, method = "IBCF")
rec = predict(rec.model, rrm,n=5)
reclist = as( rec, "list") 
df <- data.frame(matrix(unlist(reclist), nrow=7833, byrow=T),stringsAsFactors=FALSE)
df$cus_id = customer

# get all the users who are recommended with "OREO" or "CHIPS.AHOY"
df = data.table(df)
rrm_cust = df[df$X1=="OREO"|df$X1=="CHIPS.AHOY"|df$X2=="OREO"|df$X2=="CHIPS.AHOY"|df$X3=="OREO"|df$X3=="CHIPS.AHOY"|df$X4=="OREO"|df$X4=="CHIPS.AHOY"|df$X5=="OREO"|df$X5=="CHIPS.AHOY"]

# write out the outcomes
write.csv(rrm_cust, file = "promotion plan.csv",row.names=FALSE)


# part2 - discount redeemed and incremental volume

# recommend amount 
rrm2 <- as(as(cp_matrix, "matrix"), "realRatingMatrix")
rec.model2 = Recommender(rrm2, method = "IBCF")
rec2 = predict(rec.model2, rrm2, type = "ratings",n=5)
reclist2 = as( rec2, "list") 

df2 <- data.frame(matrix(unlist(reclist2), nrow=7833, byrow=T),stringsAsFactors=FALSE)
rownames(df2) = customer

# choose the top 5 recommend
rrm_cust_num = df2[,c(1:5)]
# round the volume 
rrm_cust_num = round(rrm_cust_num)
rrm_cust_num$cus_id = customer
promo_cust = rrm_cust$cus_id
# only choose the customers who will be promoted
rrm_cust_amt = rrm_cust_num[rrm_cust_num$cus_id %in% promo_cust,]

# write out the outcomes
write.csv(rrm_cust_amt, file = "promotion amount.csv",row.names=FALSE)

# oreo & chips price
data = data.table(data)
oreo = data[brand_desc=="OREO"]
oreo_price = mean(oreo$prod_unit_price)
chips_ahoy = data[brand_desc=="CHIPS AHOY"]
chips_ahoy_price = mean(chips_ahoy$prod_unit_price)

# replace the matrix with oreo & chips price or 0
rrm_tran = rrm_cust
rrm_tran[rrm_tran!="CHIPS.AHOY" & rrm_tran!="OREO"]=0
rrm_tran[rrm_tran=="OREO"]=oreo_price
rrm_tran[rrm_tran=="CHIPS.AHOY"]=chips_ahoy_price

# get average discount rate by customers
data[,avg_discount:=mean(discount_rate), by=c("cust_id")]
cus_discount= unique(data[,c("cust_id","avg_discount")])
cus_discount= cus_discount[order(cust_id),]
cus_discount_pro = cus_discount[cust_id %in% promo_cust,]

# sum up to get total value added after promotion 
price = data.frame(matrix(unlist(rrm_tran[,-6]), nrow=2004, byrow=T),stringsAsFactors=FALSE) 
amount = data.frame(matrix(unlist(rrm_cust_amt[,-6]), nrow=2004, byrow=T),stringsAsFactors=FALSE)
total_rev = sum(price%*%amount)

# write out the outcomes
write.csv(rrm_tran, file = "price.csv",row.names=FALSE)
write.csv(amount, file = "amount.csv",row.names=FALSE)
write.csv(cus_discount_pro, file = "discount.csv",row.names=FALSE)

#==========================================================================================