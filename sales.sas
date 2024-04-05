/* Reading The CSV FILE */
PROC IMPORT DATAFILE='/home/u63827732/sas train proc/sales_data.csv'
            OUT=sales_data
            DBMS=CSV
            REPLACE;
    GETNAMES=YES;
RUN;

/* checking the NULL Values */
PROC MEANS DATA=sales_data NMISS;
    VAR QuantitySold UnitPrice; 
RUN;

/* replacing missing values with average value on UnitPrice & QuantitySold Variable */
proc stdize data=sales_data reponly method=mean out=sales_data1;

var UnitPrice QuantitySold;
run;

/* rounding off the average value which we inserted */
data sales_data1;
  set sales_data1;
  UnitPrice = round(UnitPrice, 0.01);
run;


/* rounding off the average value which we inserted */
data sales_data1;
  set sales_data1;
  QuantitySold = round(QuantitySold, 1);
run;


/* Making a new column TotalSales which is the product of QuantitySold & UnitPrice */
data sales_data1;
  set sales_data1;
  TotalSales = QuantitySold * UnitPrice;
run;

/* Visualizing the Table */
proc print data=sales_data1; run;

/* Discriptive Satistics (numerical Understanding)*/
proc means data=sales_data1 noprint;
  var QuantitySold UnitPrice TotalSales;
  output out=stats_summary mean= median= max= min= /autoname;
run;

proc print data=stats_summary;
run;

/* Sort the dataset by TotalSales in descending order */
proc sort data=sales_data1 out=sales_data_sorted;
  by descending TotalSales;
run;

/* Rank the products by TotalSales */
proc rank data=sales_data_sorted out=sales_data_ranked ties=low descending;
  var TotalSales;
  ranks TotalSales_Rank;
run;

/* Filter the top 5 products */
data top_5_products;
  set sales_data_ranked (where=(TotalSales_Rank <= 5));
run;

/* Display the ProductID and total sales amount for the top 5 products */
proc print data=top_5_products noobs;   /*using noobs so that it wont give observation numbers */
  var ProductID TotalSales;
  title 'Top 5 Products by TotalSales';
run;

/* Creating group that has same date and visualizing the totalsales*/
proc sql;
  create table sales_summary as
  select Date,
         sum(TotalSales) as TotalSalesAmount,
         count(*) as TotalTransactions
  from sales_data1
  group by Date;
quit;

proc print data=sales_summary noobs;
  title 'Sales Summary by Date';
run;


