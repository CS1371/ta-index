<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <link rel='shortcut icon' type='image/x-icon' href='favicon.ico' />
        <title>CS 1371 TA Index</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link href='https://fonts.googleapis.com/css?family=Roboto:100,300,400' rel='stylesheet' type='text/css'>
        <link href='index.css' rel='stylesheet' type='text/css'>

        <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
        <script type="text/javascript" src="./js/iso.js"></script>
        <script type="text/javascript" src="./js/cells_by_row.js"></script>
    </head>
    <body>
        <div id="pageWrap">
            <div id="popupCover"></div>
            <div id="TAInfoPopup">
                <div id="closePopup">&#x2717;</div>
                <div id="TAPopupPic">
                    <div id="PopupPicDiv"></div>
                    <div id="popupTAName">
                        <div id="TAEmail"></div>
                    </div>
                </div>
                <div id="TAFunFactsSection" class="clearfix">
                    <div id="funFactsTitle">Fun Facts:</div>
                    <div id="funFactButtons" class="clearfix"></div>
                    <div class="fun-fact-container">
                        <div id="funFactTitle"></div>
                        <div id="funFactInnerText"></div>
                    </div>
                </div>
                <div id="TAInfoSection" class="clearfix">
                    <div id="recitationInfo">
                        <div class="section-title" id="recitationTitle">Recitation</div>
                        <div class="info-section-wrap border-right">
                            <div class="rec-info-section clearfix">
                                <div class="rec-info-icon teach-icon"></div>
                                <div class="rec-info-data" id="popupSection"></div>
                            </div>
                            <div class="rec-info-section clearfix">
                                <div class="rec-info-icon location-icon"></div>
                                <div class="rec-info-data" id="popupLocation"></div>
                            </div>
                            <div class="rec-info-section clearfix">
                                <div class="rec-info-icon time-icon"></div>
                                <div class="rec-info-data" id="popupTime"></div>
                            </div>
                        </div>
                    </div>
                    <div id="helpdeskInfo">
                        <div class="section-title" id="helpDeskTitle">Help Desk</div>
                        <div class="info-section-wrap"></div>
                    </div>
                </div>
            </div>           
        </div>
        <h1 id="pageTitle">Meet Your Awesome TAs</h1>
        <div id="sortCode">&gt;&gt; sort(TAList, <span id="sortByText">'Section'</span>);</div>
        <div id="sortButtons">
            <div class="sort-button" id="sortByName">Name</div>
            <div class="sort-button" id="sortBySection">Section</div>
            <div class="sort-button" id="sortByPosition">Position</div>
            <div class="sort-button" id="sortByRandom">I'm Feeling Lucky</div>
        </div>
        <div class="grid clearfix">
            <?php
                // Get INFO:
                // Info will be JSON:
                //  gtUsername
                //  title
                //  name
                //  major
                //  section
                //      name
                //      location
                //      time
                //  helpDesk (array)
                //      day
                //      time
                //  [['monday','2am-3am'],['friday','1am-3am']]
                //  funFacts (array)
                //      question
                //      answer
                // Example JSON
                
                $tmp = file_get_contents("./teachers.json");
                                // ta-block Start
                /*
                    <div class="ta-block">
                        <div class="see-more-link">See More</div>
                        <div class="ta-picture">
                            <div class="circle-pic-container" id="justingenselPic"></div>
                        </div>
                        <div class="ta-info">
                            <div class="ta-name" data-classInfo="4th year Computer Engineer">Justin Gensel</div>
                            <div class="ta-section" data-recitationLocation="Klaus 1456" data-recitationTime="R 4:30 - 5:45">D02</div>
                        </div>
                        <div class="contact-section">
                            <div class="contact-title">Contact Justin:</div>
                            <div class="contact-list">
                                <a title="desktop" href="mailto:jgensel3@gatech.edu?subject=[CS1371]" class="contact-item email" data-email="jgensel3@gatech.edu"></a>
                                <a href="https://mail.google.com/mail/?view=cm&fs=1&to=jgensel3@gatech.edu&su=[CS1371]" class="contact-item gmail"></a>
                                <a href="http://mail.live.com/default.aspx?page=Compose&to=jgensel3@gatech.edu&subject=[CS1371]" class="contact-item outlook"></a>
                            </div>
                        </div>
                    </div>
                 */
                $tas = json_decode($tmp);
                // For each TA, print example above
                foreach ($tas as $ta) {
                    echo "<div class=\"ta-block\"><a class=\"see-more-link\">See More</a><div class=\"ta-picture\"><div class=\"circle-pic-container\" id=\"";
                    if (file_exists("./images/TA_Pics/" . $ta->gtUsername . ".jpg")) {
                        echo $ta->gtUsername . "Pic\" style=\"background-image: url('./images/TA_Pics/" . $ta->gtUsername . ".jpg');\"></div>";
                    } else {
                        echo $ta->gtUsername . "Pic\" style=\"background-image: url('./images/TA_Pics/default.jpg');\"></div>";
                    }
                    
		    if (file_exists("./images/TAHorizontalPics/" . $ta->gtUsername . ".jpg")) {
                        echo "<div class=\"TA-back-exists\" data-back-exists=\"true\"> </div>";
                    } else {
                        echo "<div class=\"TA-back-exists\" data-back-exists=\"false\"> </div>";
                    }

                    if (strlen($ta->title)) {
                        echo "<div class=\"position-badge\">" . htmlspecialchars($ta->title) . "</div>";
                    }
                    echo "</div><div class=\"ta-info\" data-gt-username=\"" . $ta->gtUsername . "\"><div class=\"ta-name\" data-classInfo=\"";
                    echo htmlspecialchars($ta->major) . "\">" . htmlspecialchars($ta->name) . "</div><div class=\"ta-section\" data-recitationLocation=\"";
                    echo htmlspecialchars($ta->section->location) . "\" data-recitationTime=\"" . htmlspecialchars($ta->section->time) . "\">" . htmlspecialchars($ta->section->name) . "</div>";
                    echo "<div class=\"ta-help-desk\">";
                    // for each Help Desk, print:
                    foreach ($ta->helpDesk as $help) {
                        echo "<div data-helpdesk-day=\"" . htmlspecialchars($help->day) . "\" data-helpdesk-time=\"" . htmlspecialchars($help->time) . "\"></div>";
                    }
                    echo "</div><div class=\"TAFunFacts\">";
                    // for each Fun Fact, print:
                    foreach ($ta->funFacts as $fun) {
                        echo "<div data-fun-question=\"" . htmlspecialchars($fun->question) . "\" data-fun-answer=\"" . htmlspecialchars($fun->answer) . "\"></div>";
                    }
                    echo "</div></div>";
                    $shortName = htmlspecialchars(strtok($ta->name, " "));
                    echo "<div class=\"contact-section\"><div class=\"contact-title\">Contact " . $shortName . ":</div><div class=\"contact-list\">";
                    echo "<a title=\"desktop\" href=\"mailto:" . $ta->gtUsername . "@gatech.edu?subject=[CS1371]\" class=\"contact-item email\" data-email=\"" . $ta->gtUsername . "@gatech.edu\"></a>";
                    echo "<a href=\"https://mail.google.com/mail/?view=cm&fs=1&to=" . $ta->gtUsername . "@gatech.edu&su=[CS1371]\" class=\"contact-item gmail\"></a>";
                    echo "<a href=\"http://mail.live.com/default.aspx?page=Compose&to=" . $ta->gtUsername . "@gatech.edu&subject=[CS1371]\" class=\"contact-item outlook\"></a>";
                    echo "</div></div></div>";
                }
                
            ?>

        </div>

        <script>
            var harambeExists = false;

        $(document).ready(function(){

            hoverTimeout = null;
            $("#funFactButtons").on('mouseover','.fun-fact-button',function(e){
                clearTimeout(hoverTimeout);
                $("#funFactInnerText").html($(this).data('answer'));
                $("#funFactTitle").html($(this).data('question'));
                $(".fun-fact-container").addClass('fun-fact-container-show');
            });

            $("#funFactButtons").on('mouseleave','.fun-fact-button',function(e){
                hoverTimeout = setTimeout(function() {
                    $(".fun-fact-container").removeClass('fun-fact-container-show');
                }, 500);
            });

            function getRandomSubarray(arr, size) {
                const shuffled = arr.slice(0);
                let i = arr.length;
                while (i--) {
                    const index = Math.floor((i + 1) * Math.random());
                    const temp = shuffled[index];
                    shuffled[index] = shuffled[i];
                    shuffled[i] = temp;
                }
                return shuffled.slice(0, size);
            }

            var switchPopupText = true;


            $(".grid").on('click','.ta-block .see-more-link',function(e){
                var name = $(this).siblings('.ta-info').children('.ta-name').html();
                var username = $(this).siblings('.ta-info').attr('data-gt-username');
                var classInfo = $(this).siblings('.ta-info').children('.ta-name').attr('data-classInfo');
                var email = $(this).siblings('.contact-section').children('.contact-list').children('.email').data('email');
                var section = $(this).siblings('.ta-info').children('.ta-section').html();
                var recLocation = $(this).siblings('.ta-info').children('.ta-section').attr('data-recitationLocation');
                var recTime = $(this).siblings('.ta-info').children('.ta-section').attr('data-recitationTime');
                var positionBadge = $(this).siblings('.ta-picture').children('.position-badge');
                var helpdesk = $(this).siblings('.ta-info').children('.ta-help-desk').children();
                var helpdeskTimes = [];
                helpdesk.each(function(index) {
                    var time = $(this).attr('data-helpdesk-time');
                    var date = $(this).attr('data-helpdesk-day');
                    helpdeskTimes.push([date, time]);
                });

                var facts = $(this).siblings('.ta-info').children('.TAFunFacts').children();
                var funFacts = [];
                facts.each(function(index) {
                    var question = $(this).attr('data-fun-question');
                    var answer = $(this).attr('data-fun-answer');
                    funFacts.push([question, answer]);
                });
                if (funFacts.length > 5) {
                    var tmp = [];
                    var inds = [];
                    for (var i = 0; i < 5; i++) {
                        var ind;
                        var isUnique = false;
                        while (!isUnique) {
                            // Generate new random number
                            ind = Math.floor(Math.random() * funFacts.length);
                            // check if exists
                            isUnique = true;
                            for (var j = 0; j < inds.length; j++) {
                                if (inds[j] === ind) {
                                    isUnique = false;
                                    break;
                                }
                            }
                        }
                        tmp.push(funFacts[ind]);
                        inds.push(ind);
                    }
                    funFacts = tmp;
                }

                var allHelpDeskTimes = '';
                for(var i = 0; i<helpdeskTimes.length; i++){
                    allHelpDeskTimes += getHelpdeskDiv(helpdeskTimes[i]);
                }

                funFactSubArray = getRandomSubarray(funFacts,5);

                var allFunFacts = '';
                for(var i = 0; i < funFactSubArray.length; i++){
                    allFunFacts += getFunFactDiv(funFactSubArray[i],i+1);
                }
                allFunFacts += '<div class="fun-fact-button grad-button" data-question="Class and Major" data-answer="' + 
                    classInfo + '"></div>';


                $("#PopupPicDiv").removeClass();
                var imageUrl = null;
		if($(this).siblings('.ta-picture').children('.TA-back-exists').attr('data-back-exists')==='true'){
			imageUrl = './images/TAHorizontalPics/' + username + '.jpg';
		}else{
			imageUrl = './images/TAHorizontalPics/default.jpg';
		}
                $('#PopupPicDiv').css('background-image', 'url(' + imageUrl + ')');
                $("#PopupPicDiv").addClass(name.replace(/ /g,'').replace("'","").toLowerCase() + 'horizontal');
                $("#helpdeskInfo .info-section-wrap").html(allHelpDeskTimes);
                $("#funFactButtons").html(allFunFacts);
                $("#popupTAName").html(name + '<a href="mailto:' + email + '" id="TAEmail">' + email + '</a>');
                $("#popupSection").html(section);
                $("#popupLocation").html(recLocation);
                $("#popupTime").html(recTime);

                if(positionBadge.length && positionBadge.html().charAt(0)==='I'){
                    $("#recitationTitle").html("Lecture");
                    $("#helpDeskTitle").html("Office Hours");
                    $("#helpdeskInfo").hide();
                    $("#recitationInfo").addClass("instructor");
                } else {
                    $("#recitationTitle").html("Recitation");
                    $("#helpDeskTitle").html("Help Desk");
                    $("#helpdeskInfo").show();
                    $("#recitationInfo").removeClass("instructor");
                }

                $("#popupCover").show();
                $("#TAInfoPopup").show();

            });

            function getFunFactDiv(funFactArr,number){
                return '<div class="fun-fact-button" ' + 
                    'data-question=\"' + funFactArr[0] + '\" ' + 
                    'data-answer=\"' + funFactArr[1].replace(/"/g, "'") + '\">' + number + '</div>';
            }

            function getHelpdeskDiv(helpDeskTimeArr){
                return '<div class="rec-info-section clearfix">' + 
                    '<div class="rec-info-icon ' + helpDeskTimeArr[0] + '"></div>' + 
                    '<div class="rec-info-data">'+ helpDeskTimeArr[1] + '</div></div>';
            }

            $("#closePopup").click(function(e){
                $("#popupCover").hide();
                $("#TAInfoPopup").hide();
            });

            $(".fun-fact-label").click(function(e){
                $(".fun-fact-data").addClass('fun-fact-data-show');
            });

            var $grid = $('.grid').isotope({
                itemSelector: '.ta-block',
                layoutMode: 'cellsByRow',
                getSortData: {
                    name: '.ta-name',
                    section: '.ta-section', 
                    position: function( itemElem ) {
                        let name = $(itemElem).find('.ta-name').text();
                        var weight = $( itemElem ).find('.position-badge').text();
                        if(weight.length){
                            if (weight === "CS 1371 Swag") {
                                return 0;
                            } else if (weight === "Instructor") {
                                if (name === "David Smith") {
                                    return 1;
                                } else if (name === "Kantwon Rogers") {
                                    return 2;
                                } else {
                                    return 3;
                                }
                            } else if (weight === "Head TA") {
                                return 4;
                            } else if (weight === "Course Manager") {
                                return 5;
                            } else if (weight === "Homework Team STA") {
                                return 6;
                            } else if (weight === "Test Team STA") {
                                return 7;
                            } else if (weight === "Software Dev STA") {
                                return 8;
                            }
                        } else {
                            return 99;
                        }
                    }
                }
            });

            $("#sortByName").click(function(e){
                $grid.isotope({ sortBy : 'name' }); 
            });

            $("#sortBySection").click(function(e){
                $grid.isotope({ sortBy : 'section' }); 
            });

            $("#sortByPosition").click(function(e){
                $grid.isotope({ sortBy : 'position' }); 
            });

            $("#sortByRandom").click(function(e){
                $grid.isotope('shuffle'); 
            });

            $(".sort-button").on('click',function(e){
                $("#sortByText").html("'" + $(this).attr('id').substr(6) + "'");
            });

            $("#sortCode").on('click',function(e){
                $('#sortByText').replaceWith("<select id='sortSelect'><option>'Name'</option><option>'Section'</option><option>'Position'</option><option>'I'm Feeling Lucky'</option><option>'Waldo'</option><select>");
            });

            $("#sortCode").on('change',"#sortSelect",function(e){
                choice = $(this).find(':selected').html();
                if(choice=="'Adam'"){
                    adamBlock = $('.ta-name:contains("Adam Silverman")').parent().parent();
                    $('.ta-info').each(function(){
                        $(this).replaceWith(adamBlock.find('.ta-info').prop('outerHTML'));
                    });
                    $('.contact-section').each(function(){
                        $(this).replaceWith(adamBlock.find('.contact-section').prop('outerHTML'));                  
                    });
                    $('.ta-picture').each(function(){
                        $(this).replaceWith(adamBlock.find('.ta-picture').prop('outerHTML'));             
                    });
                    harambeExists = false;
                }else if(choice=="'Waldo'"){
                    if(!harambeExists){
                        waldoHTML = $('<div class="ta-block" style="position: absolute; left: 184px; top: 2094px;"><a class="see-more-link">See More</a><div class="ta-picture"><div class="circle-pic-container" style="background-image: url(\'./images/TA_Pics/waldo.jpg\');"></div><div class="position-badge">CS 1371 Swag</div></div><div class="ta-info" data-gt-username="waldo"><div class="ta-name" data-classinfo="20th year Hide and Seek Major">Waldo</div><div class="ta-section" data-recitationlocation="CoC 109" data-recitationtime="1:00 am - 3:00 am">TA</div><div class="ta-help-desk"><div data-helpdesk-day="monday" data-helpdesk-time="2am-3am"></div><div data-helpdesk-day="friday" data-helpdesk-time="1am-3am"></div></div><div class="TAFunFacts"><div data-fun-question="Favorite Matlab Function" data-fun-answer="why"></div><div data-fun-question="Favorite Hashtag" data-fun-answer="#wheresWaldo"></div><div data-fun-question="Favorite Homework Problem" data-fun-answer="sixDegreesOfWaldo"></div><div data-fun-question="Hobbies" data-fun-answer="Hide and Go Seek"></div><div data-fun-question="Most embarrassing story from middle school" data-fun-answer="The other kids made fun of me so I vowed to go into hiding forever"></div><div data-fun-question="Favorite quote" data-fun-answer="I\'ve never liked the recognition, the questions, the publicity. I have often felt like running away and hiding. - Al Pacino"></div><div data-fun-question="Advice to your 5th grade self" data-fun-answer="Do not listen to your friends when they say \'bet you can\'t beat me at hide and seek!\'"></div><div data-fun-question="Favorite Song" data-fun-answer="What does Waldo say"></div><div data-fun-question="I am the best in the world at:" data-fun-answer="Hide and Seek"></div><div data-fun-question="When I was 5 years old, I wanted to be a..." data-fun-answer="CS 1371 TA"></div><div data-fun-question="Best Joke" data-fun-answer="Why did Waldo go to therapy? To find himself"></div></div></div><div class="contact-section"><div class="contact-title">Contact Waldo:</div><div class="contact-list"><a title="desktop" href="mailto:waldo@gatech.edu?subject=[CS1371]" class="contact-item email" data-email="waldo@gatech.edu"></a><a href="https://mail.google.com/mail/?view=cm&amp;fs=1&amp;to=waldo@gatech.edu&amp;su=[CS1371]" class="contact-item gmail"></a><a href="http://mail.live.com/default.aspx?page=Compose&amp;to=waldo@gatech.edu&amp;subject=[CS1371]" class="contact-item outlook"></a></div></div></div>');
                        $('.grid').append( waldoHTML ).isotope( 'addItems', waldoHTML );
                        $grid.isotope({ sortBy : 'position' });
                        harambeExists = true;
                    }
                }else if(choice=="'Name'"){
                    $grid.isotope({ sortBy : 'name' });
                }else if(choice=="'Section'"){
                    $grid.isotope({ sortBy : 'section' });
                }else if(choice=="'Position'"){
                    $grid.isotope({ sortBy : 'position' });
                }else{
                    $grid.isotope('shuffle');
                }
                $('#sortSelect').replaceWith('<span id="sortByText">' + choice + '</span>');
            });


            $grid.isotope({ sortBy : 'section' });

        });
        </script>  
    </body>
</html>
