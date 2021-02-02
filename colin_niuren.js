let url = "https://us-central1-nexa-1181.cloudfunctions.net/zhipin"; //数据上传Google Storage

function slip(height,height2, duration){
    //设备宽高度根据手机尺寸可调节
    var w1 = 2;
    var w2 = 2;
    var height_1=height;
    var height_2=height2;
    //随机等待时间random（最小值，最大值）根据需要更改数值（单位秒）
    var time_random=random(1,5)*1000;
    swipe(device.width/w1,height_1,device.width/w2,height_2,duration);
    //提示等待时间。
    console.info("sleep ... " + time_random)
    sleep(time_random);
}

function CurentTime(){ 
    var now = new Date();
    var year = now.getFullYear();       //年
    var month = now.getMonth() + 1;     //月
    var day = now.getDate();            //日
    var hh = now.getHours();            //时
    var mm = now.getMinutes();          //分
    var clock = year + "-";
    if(month < 10)
        clock += "0";
    clock += month + "-";
    if(day < 10)
        clock += "0"; 
    clock += day + " ";
    if(hh < 10)
        clock += "0";
    clock += hh + ":";
    if (mm < 10) clock += '0'; 
    clock += mm; 
    return(clock);
}


auto.waitFor();
var appName = "BOSS直聘";
launchApp(appName);
sleep(3000);
toast("Launch app - " + appName);

var home = id("cl_tab_4").findOnce();
var boss_name = "";
var boss_company = "";

if(home && home.clickable()){
home.click();
sleep(4000);
id("rl_boss_base_info").findOne().click();
sleep(2000);
boss_name = id("tv_name").findOne().text()
boss_company = id("tv_brand").findOne().text()
console.info(boss_name);
console.info(boss_company);
id("iv_back").findOne().click();
}

sleep(3000);

// 进入牛人页面
var candidate = id("cl_tab_1").findOnce();
if (candidate && candidate.clickable()) {
    toast("Swicth to `牛人` tag");
    candidate.click();
    sleep(4000);


    //获取所有已发布的职位
    // var position_tabs = className("android.widget.FrameLayout").depth(18).find();
    var position_tabs = id("scroll_view").findOne().children();
    console.info("position_tabs" + position_tabs.length);
    var report_time = CurentTime();
    position_tabs.forEach(function(child, i){
        console.info("11111111");
        child.click();
        // console.info(child.children()[0].click());
        console.info("22222222");
        sleep(5000);
        console.info(child.text());
        // console.info(child.children()[0].text());
        persons(child.text(), i, report_time, boss_company, boss_name);
    });
}else{
    toast("Cannot find `牛人` tag");

    }

//牛人信息全浏览，并抓取关键数据上传Google Storage
function browse_candidate(candidate_name, position, position_index, person_index, report_time, boss_company, boss_name){
    var flag = ""
    var internal_candidate_name = id("tv_geek_name").findOne().text(); //刷新牛人姓名，避免错名情况
    var working_year = id("tv_geek_work_year").findOne().text();
    console.info(working_year);
    var status = id("tv_geek_work_status").findOne().text();
    console.info(status);
    var degree = id("tv_geek_degree").findOne().text();
    console.info(degree);

    slip(1000, 920, 30); //下滑
    var salary = id("tv_salary").findOne().text();
    console.info(salary);
    var industry = id("tv_industry").findOne().text();
    console.info("tv_industry" + industry);
    var desire_job = id("tv_job_and_city").findOne().text();
    console.info("tv_job_and_city" + desire_job);
    
    var school = "";
    var major = "";


    while(flag == ""){
        console.info("**********" + "信息下拉" + "**********");
        slip(1000, 0, 30); //下滑
    
        if(id("tv_section_title").exists()){
            id("tv_section_title").find().forEach(function(currentValue, index) {
                if(currentValue.text() == "教育经历" || currentValue.text() == "看过Ta的人还联系了"  || 
                currentValue.text() == "TA的回答" || currentValue.text() == "牛人分析器" || id("tv_edu_desc").exists()){
                    flag = currentValue.text();
                    console.info(flag);
                    console.info("===========" + "最后一次下拉" + "===========");
                    slip(1000, 0, 30); //下滑
                    var schools = id("tv_school").find();
                    var schools_list = []
                    schools.forEach(function(item, i){
                        schools_list.push(item.text())
                    });
                    school = schools_list.join(",")
                    console.info(school);

                    var majors = id("tv_degree_and_major").find();
                    var majors_list = []
                    majors.forEach(function(item, i){
                        majors_list.push(item.text())
                    });
                    major = majors_list.join(",")
                    console.info(major);
                }
            });
        }
    }
    console.info("browsed done: " + candidate_name);
    id("iv_back").findOne().click();
    payload = {
            "candidate_name": candidate_name,
            "internal_candidate_name": internal_candidate_name,
            "status": status,
            "working_year": working_year,
            "degree": degree,
            "salary": salary,
            "industry": industry,
            "desire_job": desire_job,
            "schools": school,
            "majors": major,
            "position": position,
            "position_index": position_index,
            "person_index": person_index,
            "report_time": report_time,
            "boss_name": boss_name,
            "boss_company": boss_company
            }
    let res = http.postJson(url, JSON.stringify(payload));
    let html_content = res.body.string();  //取页面html源码
    let json_content = JSON.parse(html_content);
}


//浏览当前页面所有的牛人
function operate_candidate(child, position, persions_list, position_index, report_time, boss_company, boss_name){
    var targets = child.find(className("android.widget.LinearLayout"));
    console.info(targets.length);
    targets.forEach(function (currentValue, j){
        var persons = currentValue.find(id("tv_geek_name"));
        // console.info(persons)
        persons.forEach(function(item, k){
            var abstract = item.text() + " " + position;
            console.info(abstract);
            // console.info(abstract);
            // console.info(persions_list);
            if(persions_list.indexOf(abstract) == -1){
                console.info(item.parent().clickable())
                item.parent().click();
                sleep(8000);
                browse_candidate(item.text(), position, position_index, persions_list.length, report_time, boss_company, boss_name);
                persions_list.push(abstract);
            }
            
        });
    });
}


// 下拉滚动更新牛人
function persons(position, position_index, report_time, boss_company, boss_name){
    var persions_list = []
    while(true){
        id("vp_fragment_tabs").findOne().children().forEach(function(child, i){
            console.info("sssssssss");
            if(i == position_index){
                console.info("sssssssss");
                operate_candidate(child, position, persions_list, position_index, report_time, boss_company, boss_name);
            }
        });
        console.info("----------" + "牛人下拉" + "----------");
        // slip(2010,40);
        slip(1000,0,40);
        if(persions_list.length > 30){
            console.error(persions_list);
            break
        }
    };
}
