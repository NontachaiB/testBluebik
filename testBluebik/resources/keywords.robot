*** Settings ***
Library    DatabaseLibrary
Library    RequestsLibrary
Library    SeleniumLibrary
Library    Collections
Library    Dialogs
Library    OperatingSystem
Resource    ../resources/variables.robot

*** Keywords ***
Set Product Type
    [Documentation]    ตั้งค่าการทดสอบ Product type
    [Arguments]    ${product_type}
    Set Suite Variable    ${product_type}    ${product_type}

Get Product List From API
    [Documentation]    เรียกใช้ API Method GET ตาม Product type
    Create Session    product_api    ${BASE_URL}
    ${response}=    Get Request    product_api    /products?type=${product_type}
    Set Suite Variable    ${api_response}    ${response.json()}

Verify API Response
    [Documentation]    ตรวจสอบ response API Get Product List
    [Arguments]    ${expected_status_code}
    Status Should Be    ${expected_status_code}

Start connect to Database
    [Documentation]    เชื่อมต่อ DB
    Connect To Database    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}    ${DB_HOST} 

Get Product type From Database
    [Documentation]    เชื่อมต่อและ Query ดึงข้อมูล Product type จาก Database
    Start connect to Database
    ${query}=    SELECT * FROM ${DB_NAME} WHERE product_type='${product_type}'
    ${db_data}=    Query    ${query}
    Set Suite Variable    ${db_response}    ${db_data}
    Disconnect From Database

Verify data from API and DB
    [Documentation]    ตรวจสอบข้อมูลจาก API เปรียบเทียบกับ DB
    FOR    ${product}    IN    @{api_response['products']}
        ${matching_db_product}=    Evaluate    [item for item in ${db_response} if item['id'] == ${product['id']}]
        Run Keyword And Continue On Failure    Should Be Equal    ${product['name']}    ${matching_db_product[0]['name']}
    END

Set Product name
    [Documentation]    ตั้งค่าการทดสอบ Product name
    [Arguments]    ${product_name}
    Set Suite Variable    ${product_name}    ${product_name}

Search product name from API
    [Documentation]    เรียกใช้ API Method GET ตาม Product name
    Create Session    product_api    ${BASE_URL}
    ${response}=    Get Request    product_api    /products/search?name=${product_name}
    Set Suite Variable    ${api_response}    ${response.json()}

Get Product name From Database
    [Documentation]    เชื่อมต่อและ Query ดึงข้อมูล Product name จาก Database
    Start connect to Database
    ${query}=    SELECT * FROM ${DB_NAME} WHERE product_name='${product_name}'
    ${db_data}=    Query    ${query}
    Set Suite Variable    ${db_response}    ${db_data}
    Disconnect From Database


Set Data to Add    
    [Documentation]    ตั้งค่าการทดสอบ เพิ่มสินค้าและจำนวน
    [Arguments]    ${product_id}    ${quantity}
    Set Suite Variable    ${product_id}    ${product_id}
    Set Suite Variable    ${quantity}    ${quantity}

Add Product To Cart API
    [Documentation]    เรียกใช้ API method Post ทำการเพิ่มสินค้าลงตะกร้า
    Create Session    cart_api    ${BASE_URL}
    ${payload}=    Create Dictionary    product_id=${product_id}    quantity=${quantity}
    ${response}=    Post Request    cart_api    /cart/add    json=${payload}
    Set Suite Variable    ${api_response}    ${response.json()}

Verify API add to cart response
    [Documentation]    ตรวจสอบ response API Add Product To Cart API 
    [Arguments]    ${expected_status_code}
    Status Should Be    ${expected_status_code}
    Log    เพิ่มสินค้าสำเร็จ

Verify Product added to Cart on website
    [Documentation]    ตรวจสอบว่าสินค้าถูกเพิ่มลงในตะกร้าสินค้าของผู้ใช้บนหน้าเว็บ
    Open Browser    ${WEB_URL}    chrome
    Go To    ${WEB_URL}/user_id/cart
    Wait Until Page Contains Element    xpath=//div[@data-product-id="${product_id}"]
    Element Text Should Be    xpath=//div[@data-product-id="${product_id}"]//span[@class="quantity"]    ${quantity}
    Log    สินค้าถูกเพิ่มในตะกร้าของผู้ใช้ถูกต้อง
    Close Browser

Get Cart Data From Database
    [Documentation]    เชื่อมต่อและ Query ดึงข้อมูลสินค้าในตะกร้า จาก Database
    Connect To Database
    ${query}=    SELECT * FROM ${CART} WHERE product_id='${product_id}' AND user_id='${USER_ID}'
    ${db_data}=    Query    ${query}
    Set Suite Variable    ${db_response}    ${db_data}
    Disconnect From Database

Verify Product Added To Database
    [Documentation]    ตรวจสอบข้อมูลที่เพิ่มขึ้นมาใน Database
    ${matching_db_product}=    Evaluate    ${db_response}[0]
    Run Keyword And Continue On Failure    Should Be Equal    ${matching_db_product['product_id']}    ${product_id}
    Run Keyword And Continue On Failure    Should Be Equal    ${matching_db_product['quantity']}    ${quantity}
    Log    สินค้า    ${product_id}    ถูกเพิ่มขึ้นมา    ${quantity}    หน่วย


Set User Data
    [Documentation]    ตั้งค่าผู้ใช้สำหรับใช้การทดสอบ
    [Arguments]    ${user_id}
    Set Suite Variable    ${user_id}    ${user_id}

View User Cart Items API
    [Documentation]    Send a GET request to retrieve the cart items for a user
    Create Session    cart_api    ${BASE_URL}
    ${response}=    Get Request    cart_api    /cart/items?user_id=${user_id}
    Set Suite Variable    ${api_response}    ${response.json()}

Verify API View User Cart Items response
    [Documentation]    ตรวจสอบ response จาก View User Cart Items API 
    [Arguments]    ${expected_status_code}
    Status Should Be    ${expected_status_code}

Get User Cart Items From DB
    [Documentation]    เชื่อมต่อและ Query ข้อมูลสินค้าใน Cart ของผู้ใช้
    Connect To Database
    ${query}=    SELECT * FROM ${CART} WHERE user_id='${user_id}'
    ${db_data}=    Query    ${query}
    Set Suite Variable    ${db_response}    ${db_data}
    Disconnect From Database

Verify Cart Items From API and DB
    [Documentation]    เปรียบเทียบข้อมูลของผู้ใช้จากการเรียกผ่าน API และ DB 
    ${api_cart_items}=    Evaluate    ${api_response['cart_items']}
    ${db_cart_items}=    Evaluate    [item for item in ${db_response}]
    FOR    ${api_item}    IN    @{api_cart_items}
        ${matching_db_item}=    Evaluate    [item for item in ${db_cart_items} if item['product_id'] == ${api_item['product_id']}]
        Run Keyword And Continue On Failure    Should Be Equal    ${api_item['product_id']}    ${matching_db_item[0]['product_id']}
        Run Keyword And Continue On Failure    Should Be Equal    ${api_item['quantity']}    ${matching_db_item[0]['quantity']}
    END
    Log    รายการสินค้าในตะกร้าสินค้าถูกต้อง

Set Product To Remove
    [Documentation]    ตั้งค่า id รายการสินค้าสำหรับใช้การทดสอบ
    [Arguments]    ${product_id}
    Set Suite Variable    ${product_id}    ${product_id}

Remove Item From User Cart API
    [Documentation]    Send a DELETE request to remove the product from the cart
    Create Session    cart_api    ${BASE_URL}
    ${response}=    Delete Request    cart_api    /cart/item?user_id=${user_id}&product_id=${product_id}
    Set Suite Variable    ${api_response}    ${response.json()}

Verify API Remove Item From User Cart response
    [Documentation]    ตรวจสอบ response จาก Remove Item From User Cart 
    [Arguments]    ${expected_status_code}
    Status Should Be    ${expected_status_code}

Verify Item Remove from Cart on website
    [Documentation]    ตรวจสอบตะกร้าสินค้าผู้ใช้บน Web ถูกลบออก
    Open Browser    ${WEB_URL}    chrome
    Go To    ${web_url}/cart?user_id=${user_id}
    Element Should Not Contain    //div[@class='cart-item']    ${product_id}
    Log    สินค้าในตะกร้าของผู้ใช้ถูกลบออกแล้ว
    Close Browser

Get User Cart Items After Remove From DB
    [Documentation]    เชื่อมต่อและ Query ข้อมูลหลังจาก Remove สินค้าในตะกร้าของผู้ใช้
    Connect To Database
    ${query}=    SELECT * FROM ${CART} WHERE user_id='${user_id}' AND product_id='${product_id}'
    ${db_data}=    Query    ${query}
    Set Suite Variable    ${db_response}    ${db_data}
    Disconnect From Database

Verify Database After Removed Items
    [Documentation]    Verify that the item has been removed from the user's cart in the database
    ${db_cart_items}=    Evaluate    [item for item in ${db_response}]
    Should Be Empty    ${db_cart_items}    " "
    Log    สินค้าถูกลบออกจากตะกร้าของผู้ใช้แล้ว