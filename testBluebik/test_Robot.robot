*** Settings ***
Documentation   Test Bluebik
Resource    resources/variables.robot
Resource    resources/keywords.robot


*** Test Cases ***

TC01 ทดสอบการเรียก API เพื่อแสดงรายการสินค้า
    [Documentation]   ทดสอบเรียก API ค้นหา Product type
    [Tags]    TC01
    # ตั้งค่า Product type
    Set Product Type    smartphone

    # เรียก API เพื่อแสดงรายการสินค้า
    Get Product List From API
    
    # Verify API Response
    Verify API Response    200

    # เชื่อมต่อ DB และ แสดงรายการสินค้าใน DB
    Get Product type From Database

    # ตรวจสอบเปรียบเทียบรายการสินค้าที่ส่งกลับจาก API กับรายการสินค้าในฐานข้อมูล
    Verify data from API and DB 

    # จบการทำงาน TC01
    Disconnect From All Databases
    

TC02 ทดสอบการเรียก API เพื่อค้นหาสินค้า
    [Documentation]   ทดสอบเรียก API ค้นหาชื่อ Product
    [Tags]    TC02
    # ตั้งค่า Product name
    Set Product name    iPhone 14

    # เรียก API สำหรับการค้นหารายการสินค้าที่ตรงตามชื่อ
    Search product name from API    

    # Verify API Response
    Verify API Response    200    

    # เชื่อมต่อ DB และ แสดงรายการสินค้าใน DB
    Get Product name From Database

    # ตรวจสอบข้อมูลจาก API เปรียบเทียบกับ DB
    Verify data from API and DB

    # จบการทำงาน TC01
    Disconnect From All Databases


TC03 ทดสอบการเรียก API เพื่อเพิ่มสินค้าลงในตะกร้าสินค้า
    [Documentation]    ทดสอบเพิ่มสินค้าในตะกร้าของผู้ใช้
    [Tags]    TC03
    # ตั้งค่า Product id และ จำนวน ที่จะเพิ่ม
    Set Data to Add    12345    1

    # เรียก API สำหรับเพิ่มรายการสินค้า
    Add Product To Cart API

    # Verify API Response
    Verify API add to cart response    200

    # ตรวจสอบหน้าการเพิ่มสินค้าในตะกร้าที่หน้า Website 
    Verify Product added to Cart on website

    # เชื่อมต่อ DB และ แสดงรายการสินค้าใน DB
    Get Cart Data From Database

    # ตรวจสอบข้อมูลใน DB หลังจากเพิ่มสินค้าเข้าตะกร้า
    Verify Product Added To Database
    
TC04 ทดสอบการเรียก API เพื่อแสดงรายการสินค้าในตะกร้าสินค้า
    [Documentation]   ทดสอบแสดงรายการสินค้าของผู้ใช้ใน cart
    [Tags]    TC04
    # ตั้งค่า User id
    Set User Data    12345

    # เรียก API สำหรับดูรายการสินค้า
    View User Cart Items API

    # Verify API Response
    Verify API View User Cart Items response    200    

    # เชื่อมต่อ DB และ แสดงสินค้าในตะกร้าใน DB
    Get User Cart Items From DB

    # ตรวจสอบข้อมูลจาก API เปรียบเทียบกับ DB
    Verify Cart Items From API and DB


TC05 ทดสอบการเรียก API เพื่อลบสินค้าออกจากตะกร้าสินค้า
    [Documentation]    ทดสอบลบสินค้าออกจากตะกร้าสินค้าและตรวจสอบว่าข้อมูล บน Web และ Database ถูกลบ
    [Tags]    TC05
    # ตั้งค่า User id
    Set User Data    12345

    # ตั้งค่า Product id ที่ทำการทดสอบลบ
    Set Product To Remove    12345

    # เรียก API สำหรับลบสินค้าออกจากตะกร้า
    Remove Item From User Cart API

    # Verify API Response
    Verify API Remove Item From User Cart response    200

    # ตรวจสอบรายการที่ถูกลบบนหน้า Website
    Verify Item Remove from Cart on website

    # เชื่อมต่อ DB และ แสดงสินค้าในตะกร้าใน DB
    Get User Cart Items After Remove From DB

    # ตรวจสอบข้อมูลสินค้าถูกลบออกจาก DB
    Verify Database After Removed Items






#py -m robot -d report -i TC01 test_Robot.robot  
#py -m robot -d report -e test_Robot.robot
#py -m robot -d report test_Robot.robot