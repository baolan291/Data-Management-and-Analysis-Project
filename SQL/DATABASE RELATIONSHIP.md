DATABASE RELATIONSHIP



1\. customers

\- customer\_id

\- customer\_name

\- region



2\. suppliers

\- supplier\_id

\- supplier\_name

\- supplier\_region

\- lead\_time\_days



3\. warehouses

\- warehouse\_id

\- warehouse\_name

\- region



4\. products

\- product\_id 

\- product\_name

\- category

\- supplier\_id **(2)**

\- unit\_cost

\- unit\_price



5\. orders 

\- order\_id

\- customer\_id **(1)**

\- warehouse\_id **(3)**

\- order\_date

\- status



6\. order\_items

\- order\_item\_id

\- order\_id **(5)**

\- product\_id **(4)**

\- quantity

\- unit\_price



7\. inventory

\- inventory\_id

\- warehouse\_id **(3)**

\- product\_id **(4)**

\- inventory\_date

\- stock\_level

\- reorder\_point



8\. shipments

\- shipment\_id

\- order\_id **(5)**

\- ship\_date

\- expected\_delivery\_date

\- actual\_delivery\_date

\- carrier

\- shipment\_cost



products - suppliers

orders - customers

orders - warehouses

order\_items - orders

order\_items - products

inventory - warehouses

inventory - products

shipments - orders



