# Market-Campaign---based-on-Reccomender-System
Apply Item based Collaborative Filtering to help with marketing campaign decision on two products
Executive Summary
Pernalonga, a leading supermarket chain, is partnering with one of its suppliers Mondelez to promote Oreo and Chips Ahoy! brand to gain market share in the Fine Wafers category, with marketing campaigns on personalized promotions. After analyzing transaction data on customers who purchased either in the Fine Wafers category or the Oreo or Chips Ahoy! brand, we conducted item-based collaborative filtering on 7,833 customers and 35 products to come up with customers to target with promotional offers for either Oreo or Chips Ahoy! wafers. A detailed list of customer IDs, expected incremental volumes and promotional offer discount rate is attached along with this report.
For this marketing campaign, Mondelez should target 688 customers for Oreo fine wafers, and 1,418 customers for Chips Ahoy! fine wafers, generating incremental volumes of 2,403 units and 5,491 units, respectively. Combining with unit price and average discount rates, this leads to an incremental revenue of $16,902, contributing to a 1.5% market share gain in the Fine Wafers category. 
On the flip side, since promotion offer discount rates are on average greater than profit margin, redemption costs for this marketing campaign will outweigh the profits generated with these incremental sales. Assuming a profit margin of 3%, running this campaign will lead to a loss of $3,935 for Mondelez.
As we can see here, besides gaining market share, Mondelez also have to consider the costs associated with these personalized promotion marketing campaigns – redemption costs often outweigh the profits generated. Mondelez have to measure long-term costs and benefits associated with market expansion to determine a strategy to strike a balance between gaining market share and maintaining a healthy bottom line.

 
Background
Pernalonga is a leading supermarket chain in Lunitunia, selling over 10,000 products in more than 400 categories. Currently, Pernalonga offers mainly in-store promotions, which are not the most beneficial as they offer temporary price cuts to customers regardless of their needs. Customers who may not be willing to purchase the products are targeted as well, leading to some inefficiencies in the in-store promotions. Therefore, Pernalonga wants to explore another promotion tactic: personalized promotions. Marketing campaigns with personalized promotions target individuals who are most likely to purchase a product and offer these individuals a personalized promotion offer to maximize incremental sales and profits.
Pernalonga has partnered with one of the suppliers Mondelez to develop a marketing campaign to experiment on personalized promotions. Mondelez is looking to promote its Oreo and Chips Ahoy! brands to increase its market share in the Fine Wafers category. As a consulting team, our goal is to analyze customer transaction data to develop a marketing campaign using personalized promotions for Mondelez to increase its Fine Wafers market share.  

Data Preparation and Assumptions
In order to come up with customers who are likely to purchase either the Oreo brand or the Chips Ahoy! brand fine wafers, we first need to understand Pernalonga’s roughly 28 million transaction data of 7,920 customers and 10,767 products. After some initial explorations, we decided to focus on customers who either have purchased in the Fine Wafers category, or have purchased Oreo and Chips Ahoy! brand products for further analysis. We are assuming that customers who purchase Fine Wafers category products but not necessarily Oreo or Chips Ahoy! most likely have the need or preference for wafers, so they have the potential to switch to Oreo or Chips Ahoy! with some promotional offers. For customers who are already purchasing the Oreo and Chips Ahoy! brands but not necessarily the wafers, they have the brand loyalty to try out other products by the same Oreo or Chips Ahoy! brand, and therefore will be the focus of our analysis as well. For customers who have never purchased Fine Wafers or Oreo or Chips Ahoy! brand products, we are assuming that they have no need or preference for fine wafers and will not be interested in fine wafers by Oreo or Chips Ahoy! even if given promotional offers. 
Since part of the marketing campaign agreement mentions that customers who purchase Pernalonga’s private label equivalent of the promoted brand should not be targeted for promotion offers, we eliminated these customers for our analysis as well. 
After these initial data preparation process mentioned above, we have 373,300 rows of transaction data for 7,833 customers who either purchased Fine Wafers or Oreo-brand products or Chips Ahoy!’s products for further exploration and analysis.

Data Exploration
We want to explore the data set to understand how the two brands of interest are doing among other brands in the overall Fine Wafers category.

Measures/Brand	CHIPS AHOY	OREO	FINE WAFERS
Total sales (rounded to nearest dollar)	$16,687	$144,825	$1,269,788
Total Sales after Discount
(rounded to nearest dollar)	$13,237	$101,913	$893,010
Quantity (CT)	5,662 units	47,401 units	462,243 units
Discount Frequency
(% of transactions bought on sale)	48.1%	57.3%	57.5%
Average Discount Amount
($ per sale)	$0.72	$1.01	$1.01
Total Unique Customers	1,596	5,719	7,832
Figure 1: Chips Ahoy! and Oreo Compared to Fine Wafers Category
The table above shows Mondelez’s current two products that they considering to promote (Chips Ahoy and Oreo) as well as the total Fine Wafers Industry. Based on the results, we can see that why Mondelez wants to push these products. Starting with Chips Ahoy, although the brand’s sales only makes up 1% of the entire Fine Wafers Industry sales, they have an increasing amount of customers who are willing to buy the product at a fairly high discount frequency of 48%. This should attract more customers down the line, especially if Mondelez does more personalized promotions.
On the other hand, Oreos have a larger presence in the Fine Wafers Industry. Their sales ($144,825) make up roughly 12% of the total Fine Wafers sector and have sold 47,401 units (10% of the total). The Sales of both Oreos and Chips Ahoy compared to the Fine Wafers Industry is shown below:
 
Figure 2: Oreo and Chips Ahoy! Market Share
Furthermore, Oreo’s have a larger discount frequency of 57.3%. This means that over half of their products have been sold on ‘Sale’ (A timeframe when a firm lowers their prices in order for customers to buy products). This is very interesting to note as if Mondelez were to increase their ‘Sale’ period of Oreos in the long run, they should see a dramatic increase in their sales and revenue. Furthermore, Oreos have an average discount amount of $1.01 which is on par with the Industry value. 
After analyzing both brands that Mondelez is trying to promote from an overview, we started to dive deeper and look at the transaction sale quantity and price in order to find patterns and trends. The graph below shows the price against quantity for all products in the Fine Wafers Industry, where Oreos and Chips Ahoy and marked in dark grey, and the other products in light blue:
 
Figure 3: Price vs. Quantity for Brands of Interest Compared to Others
What we found interesting is that the majority of both Oreos and Chips Ahoy are sold at lower prices at a low quantity. The low pricing makes sense, since 57 % of Oreos and 48% of Chips Ahoy are sold during ‘Sale’. However, if Mondelez wants these brands to be the industry leaders in term of revenue, they need to promote these products in a way that will help increase their number of units sold. 

Modeling Approaches
After we explored the data to have a better understanding of these two brands that we are promoting, we decided to construct a Recommender System using collaborative filtering, to come up with customers to target for Mondelez’s marketing campaign and predict total redemption cost and incremental volume.
Collaborative filtering is the most popular method for generating recommendations, widely used in e-commerce, social media and entertainment sites. It uses customer preferences and patterns in the data to predict individual preference on a particular product item. There are two types of collaborative filtering: user-based collaborative filtering and item-based collaborative filtering.
User-based collaborative filtering assumes that similar people will have similar taste. It recommends items by finding similar customers and creates an artificial rating on an item of interest based on customer similarity.
Item-based collaborative filtering focuses on the similarities between product items, and the predictive rating is based on how similar an item of interest is to the product items a customer is already purchasing. 
We investigated both types of collaborative filtering to determine which one yields a better result in recommending customers to target. We used our pre-cleaned data set of 373,300 rows of transaction data for 7,833 customers, to construct a matrix of unique customers and unique products/brands. The matrix structure is shown below.
Customers/Products	FLORBÚ	NACIONAL	…	FILIPINOS	CARR'S
31229829					
31079582					
…					
27419620					
89249557					
Figure 4: Matrix Structure Demo
Since there are 7,833 unique customers and 35 unique products in the data set, we have a 7,833 x 35 matrix. Each element of the matrix contains the frequency at which a customer shops each product. If the customer has never purchased the product before, an NA is assigned instead. The complete matrix is then normalized to have similarity measures at a comparable scale. In order to compare user-based and item-based collaborative filtering performance, we split the matrix into a training data and a test set. The test set is then used to compare errors and accuracy performance between user-based and item-based collaborative filtering. The results are as follows: 
	RMSE	MSE	MAE
User-based Collaborative Filtering (UBCF)	
1.24	
1.54	
0.70
Item-based Collaborative Filtering (IBCF)	
0.93	
0.87	
0.61
Figure 5: Performance Comparison between UBCF and IBCF
As we can see from the chart, item-based collaborative filtering has smaller prediction errors compared to user-based collaborative filtering, so we decided to use item-based collaborative filtering to generate predictions. The collaborative filtering model predicts ratings on the 35 products for each customer, and we will take the top 5 products with the highest ratings as products that the customer is likely to purchase. Customers who have Oreo or Chips Ahoy! in their top 5 product recommendations will be our target in the Mondelez marketing campaign. As we can see in the sample output below, customer id.109693 will be targeted for Oreo wafers promotions, and customer id.169587, 189709, 299749, 339665 will be targeted for Chips Ahoy! wafers promotions.
Product Recommendations	Customers
BALCONI	OREO	NUTELLA	DAN.CAKE	ARTIACH	109693
DELIPICK.	CHIPS.AHOY	VIEIRA..DE.CASTRO	FLORBÚ	LAMBERTZ	169587
LA.BURGALESA	DULCA	PROALIMENTAR	CHIPS.AHOY	BALCONI	189709
FRUTOP	DAILIDOCE	CARR.S	CHIPS.AHOY	LAMBERTZ	299749
CHIPS.AHOY	NACIONAL	FLORBÚ	CUETARA	DELIPICK.	339665
Figure 6: Sample Product Recommendation Output
With the target customers identified, we can also apply item-based similarity within these customers to predict the volume these customers will purchase for either Oreo or Chips Ahoy! wafers using an unnormalized matrix. The sample output is as follows. Combining the volumes with the product of interest, we can see that for these 5 customers, with the marketing campaign we are expected to generate incremental volumes of 3 units of Oreo, and 19 units of Chips Ahoy!.
Expected Incremental Product Volumes	Customers
3	3	2	3	1	109693
5	4	5	5	5	169587
7	6	6	7	7	189709
5	3	5	6	6	299749
2	2	2	2	2	339665
Figure 7: Sample Expected Incremental Product Volumes Output

With the expected product volumes, we also want to estimate the total redemption costs for the marketing campaign, in other words, the total discounts redeemed in the campaign. We assume that customers’ willingness to pay vary from transactions to transactions, so we will use average discount rates by customers as a proxy for the discount rates in this calculation. We can also obtain average prices of Oreo and Chips Ahoy, combining that with the incremental quantities and discount rates by customers, to come up with total redemption costs for the Mondelez marketing campaign.
Marketing Campaign Details and Conclusion
After aggregating and summarizing our item-based collaborative filtering model results, we have the proposed details for the Mondelez marketing campaign on personalized promotions. Mondelez should target 688 customers for Oreo fine wafers, and 1,418 customers for Chips Ahoy! fine wafers, generating incremental volumes of 2,403 units and 5,491 units, respectively. The details of the customer id, expected incremental volumes and promotion offer discount rate are provided in “campaign_details.csv”. A sample of the file is provided below.
Customers to Target 
for Oreo	Expected Incremental 
Volumes	Promotion Offer
Discount Rate
109693	3	17%
349530	1	20%
529915	4	30%
899987	5	44%
949967	4	40%
Figure 8: Sample Campaign Details for Oreo
Customers to Target 
for Chips Ahoy!	Expected Incremental 
Volumes	Promotion Offer
Discount Rate
169587	4	20%
189709	7	31%
299749	6	23%
339665	2	37%
339918	3	30%
Figure 9: Sample Campaign Details for Chips Ahoy!
As we have seen from the data exploration, Mondelez can increase sales for their brands by promoting bulk buying and targeting the right customers with personalized promotions. The incremental sales volumes and incremental revenue will lead to a larger market share of the Fine Wafers category. Besides the revenue perspective, we also have to consider costs in this scenario – the total redemption costs for these promotions. Total discounts redeemed is calculated to be $4,442, whereas the total incremental revenue is $16,902. Assume a profit margin of 3%, the incremental revenue is translated to be a profit of $507, without considering the promotions. The redemption costs of $4,442 is bigger than the profits that Mondelez would have made with these incremental sales transactions. This means that even though the marketing campaign will contribute to a gain of market share of Mondelez, they also have to consider the costs associated with the campaigns – redemption costs often outweigh the profits generated. Mondelez have to consider the internal costs and benefits associated with personalized promotion marketing campaign and determine a strategy to strike a balance between gaining market share and maintaining a healthy bottom line. 
 
Technical Appendix
Marketing Analysis Project2 RS – R Code.R
