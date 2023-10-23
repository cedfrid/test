WITH swedish_comapnies_table AS (

SELECT dim.OrgNr AS Company_orgno
  ,dim.OrgNo AS OrgNo
  ,dim.CompanyName AS Foretagsnamn
  ,dim.LegalGroupText
  ,dim.PostTown AS UC_Ort
  ,dim.PostStreetName AS UC_Adress 
  ,dim.PostZipCode AS UC_Postnr

FROM `visma-marketing-cloud-master`.SpcsSE_Warehouse.whs_dim_company_data dim
WHERE dim.dbt_valid_to IS NULL 
AND dim.LegalGroupText = 'Aktiebolag' --IN ('Privat aktiebolag', 'Aktiebolag')
AND dim.LegalGroupCode = 'AB'
),

spcs_customers_table AS (

SELECT --dc.CustKey,
   dc.CustName AS KundNamn
  ,dc.OrgNo 
  --,dp.ProductLine
  ,dp.Product AS Produkt
  ,dc.CustGroupCode AS Kundgrupp
  ,dc.City AS Ort
  ,dc.Address
  ,dc.PostalCode AS PostNr
  --,cc.ClientCustNo
  --,cc.ChargeToCustomer
  --,da.AgreementStartDate 
  --,da.AgreementRemovalDate
  --,da.dbt_valid_to 
FROM `visma-marketing-cloud-master`.SpcsSE_Warehouse.whs_dim_customer dc

JOIN `visma-marketing-cloud-master`.SpcsSE_Warehouse.whs_dim_agreement da   
  ON da.CustKey = dc.CustKey 
  AND da.dbt_valid_to IS NULL
  AND da.AgreementRemovalDate IS NULL 

LEFT JOIN `visma-marketing-cloud-master`.SpcsSE_Warehouse.whs_dim_collaborations cc
  ON cc.ClientCustKey  = dc.CustKey 
  AND cc.AgreementKey = da.AgreementKey
  AND cc.dbt_valid_to IS NULL 

JOIN `visma-marketing-cloud-master`.SpcsSE_Warehouse.whs_dim_product dp
  ON dp.ProdKey = da.ProdKey 
  AND dp.dbt_valid_to IS NULL
  AND dp.ProductLine ="Visma eAccounting"
  --AND dp.Product ="eEkonomi Start"--, "eEkonomi Bokföring","eEkonomi Bas","eEkonomi Fakturering")
  AND dp.IsMainAgreement = TRUE
WHERE dc.dbt_valid_to IS NULL 
  AND dc.CustGroupCode not in (9010, 999, 1800, 1910) 
  AND (cc.ChargeToCustomer IS NULL OR cc.ChargeToCustomer = TRUE)
  AND dc.CustGroupCode NOT BETWEEN 1800 AND 1899
  AND dc.CustGroupCode NOT BETWEEN 1 AND 999
  AND dc.CustGroupCode != 1260
  AND dp.Product != "eEkonomi Start"

)

SELECT * 
FROM swedish_comapnies_table a
JOIN spcs_customers_table b
ON a.OrgNo = b.Orgno