// Import the commonReactions library so that you don't have to worry about coding the pre-programmed replies
import "commonReactions/all.dsl";

context
{
// Declare the input variable - phone. It's your hotel room phone number and it will be used at the start of the conversation.  
    input phone: string;
    output new_time: string="";
    output new_day: string="";
// Storage variables. You'll be referring to them across the code.
    food: {[x:string]:string;}[] = [];
    pizza: {[x:string]:string;}[]?=null;
    appetizers: {[x:string]:string;}[]?=null;
    main_dishes: {[x:string]:string;}[]?=null;
    drinks: {[x:string]:string;}[] = [];
    forgotten_thing: {[x:string]:string;}[]=[];
}

// A start node that always has to be written out. Here we declare actions to be performed in the node. 
start node root
{
    do
    {
        #connectSafe($phone); // Establishing a safe connection to the hotel room's phone.
        #waitForSpeech(1000); // Waiting for 1 second to say the welcome message or to let the hotel guest say something
        #sayText("Hi, this is Butterfly Resort Hotel reception. How may I help you?"); // Welcome message
        wait *; // Wating for the hotel guest to reply
    }
    transitions // Here you give directions to which nodes the conversation will go
    {
        // Transitions could be written out here, in which case you'd need to write out corresponding nodes. Otherwise, the conversation will go to a digression triggered by a specific intent
    }
}

digression cleaning // Digressions can be triggered at any moment of the conversation. 
{
    conditions {on #messageHasIntent("cleaning");} // This digression is triggered when a person says something that is related to the room cleaning service. The intents are written out in the data.json file.
    do // Once this digression is triggered, here's what Dasha AI will do
    {
        #sayText("Absolutely, someone will come up to your room in approximately 10 minutes. Is there anything else I can help you with?");
        wait *; // Waiting for the person to either end the call, proceed to asking more questions, etc. The AI doesn't say anything before hears a human speak.
    }
}

digression order 
{
    conditions {on #messageHasIntent("order");}
    do
    {
     #sayText("Sure thing. What would you like to order?");
     wait *;
    }
    transitions
    {
        menu: goto menu on #messageHasIntent("menu") or #messageHasIntent("unsure"); // In this case we expect the hotel guest not knowing what's on the hotel restautant's menu, therefore we will make a transition to the menu node
    }
}

node menu
{
    // Note that you don't write conditions for nodes (compared to digressions).
    do
    {
        #sayText("We have various appetizers, pizza, main dishes and drinks. What would you like to get?");
        wait *;
    }
    transitions // 4 options of different types of food/drinks. 
    {
        appetizers: goto appetizers on #messageHasIntent("appetizers");
        pizza: goto pizza on #messageHasIntent("pizza");
        main_dishes: goto main_dishes on #messageHasIntent("main_dishes");
        drinks: goto drinks on #messageHasIntent("drinks");
    }
}

node appetizers
{
    do 
    {
        #sayText("We've got fried calamari, french fries, spring salad, and a soup of the day. What of these would you like to order?");
        wait *;
    }
    transitions 
    {
       confirm_food_order: goto confirm_food_order on #messageHasData("food"); // We have an entity here - food. It's written out in the data.json file under entities.
    }
     onexit // Specifies an action that Dasha AI should take, as it exits the node. The action must be mapped to a transition
    {
        confirm_food_order: do {
               set $appetizers =  #messageGetData("food", { value: true }); // Dasha AI will remember what has been ordered and will update the "food" variable. "value: true" will return all results that have a value field
       }
    }
}

digression appetizers
{
    conditions {on #messageHasIntent("pizza_kind");}
    do 
    {
        #sayText("We've got fried calamari, french fries, spring salad, and a soup of the day. What of these would you like to order?");
        wait *;
    }
    transitions 
    {
       confirm_food_order: goto confirm_food_order on #messageHasData("food");
    }
     onexit
    {
        confirm_food_order: do {
               set $appetizers =  #messageGetData("food", { value: true });
       }
    }
}

node pizza
{
    do 
    {
        #sayText("We have Pepperoni, Cheese, and Veggie pizzas. Which one would you like?");
        wait *;
    }
    transitions 
    {
        confirm_food_order: goto confirm_food_order on #messageHasData("food");
        no_dice_bye: goto no_dice_bye on #messageHasIntent("never_mind");
    }
     onexit
    {
        confirm_food_order: do {
               set $food =  #messageGetData("food", { value: true });
       }
    }
}

digression pizza
{
    conditions {on #messageHasIntent("pizza_kind");}
    do 
    {
        #sayText("Umm, we have Pepperoni, Margherita, and Veggie pizza. Which one would you like?");
        wait *;
    }
    transitions 
    {
        confirm_food_order: goto confirm_food_order on #messageHasData("food");
        no_dice_bye: goto no_dice_bye on #messageHasIntent("never_mind");
    }
     onexit
    {
        confirm_food_order: do {
               set $food =  #messageGetData("food", { value: true });
       }
    }
}

node main_dishes
{
    do 
    {
        #sayText("Main dishes wise we have mushroom tortellini, baked honey mustard chicken, pasta carbonara, and vietnamise porkchops. What would you like to get?");
        wait *;
    }
    transitions 
    {
       confirm_food_order: goto confirm_food_order on #messageHasData("food");
    }
    onexit
    {
        confirm_food_order: do {
        set $main_dishes = #messageGetData("food");
       }
    }
}

digression main_dishes
{
    conditions {on #messageHasIntent("main_dishes");}
    do 
    {
        #sayText("Main dishes wise we have mushroom tortellini, baked honey mustard chicken, pasta carbonara, and vietnamise porkchops. What would you like to get?");
        wait *;
    }
    transitions 
    {
       confirm_food_order: goto confirm_food_order on #messageHasData("food");
    }
    onexit
    {
        confirm_food_order: do {
        set $main_dishes = #messageGetData("food");
       }
    }
}

node drinks
{
    do 
    {
        #sayText("We have orange juice, Sprite, and vanilla milkshakes. What would you like to get?");
        wait *;
    }
    transitions 
    {
       confirm_drinks: goto confirm_drinks on #messageHasData("drinks");
    }
    onexit
    {
        confirm_drinks: do {
        set $drinks = #messageGetData("drinks");
       }
    }
}

digression drinks
{   
    conditions {on #messageHasIntent("drinks");}
    do 
    {
        #sayText("We have orange juice, Sprite, and vanilla milkshakes. What would you like to get?");
        wait *;
    }
    transitions 
    {
       confirm_drinks: goto confirm_drinks on #messageHasData("drinks");
    }
    onexit
    {
        confirm_drinks: do {
        set $drinks = #messageGetData("drinks");
       }
    }
}

node confirm_drinks
{
    do
    {
        var sentence = "Alright, you want ";
        set $drinks = #messageGetData("drinks");
        for (var item in $drinks) {
            set sentence = sentence + (item.value ?? "and"); // In case the guest desides to order multiple items of food
        }
        set sentence = sentence + ". Did I get that right?";
        #sayText(sentence); 
        wait *;
    }
     transitions 
    {
        order_confirmed: goto order_confirmed on #messageHasIntent("yes");
        repeat_order: goto repeat_order on #messageHasIntent("no");
    }
}

node confirm_food_order
{
    do
    {
        var sentence = "Perfect. Let me just make sure I got that right. You want ";
        set $food = #messageGetData("food");
        for (var item in $food) {
            set sentence = sentence + (item.value ?? " and ");
        }
        set sentence = sentence + ". Is that right?";
        #sayText(sentence); 
        wait *;
    }
     transitions 
    {
        order_confirmed: goto order_confirmed on #messageHasIntent("yes");
        repeat_order: goto repeat_order on #messageHasIntent("no");
    }
}

node repeat_order
{
    do 
    {
        #sayText("Let's try this again. What can I get for you today?");
        wait *;
    }
    transitions 
    {
       confirm_food_order: goto confirm_food_order on #messageHasData("food");
       confirm_drinks: goto confirm_drinks on #messageHasData("drinks");
    }
}

node order_confirmed
{
    do
    {
        #sayText("Your order will be ready in 15 minutes. We'll bring it straight to your room! Anything else I can help you with? ");
        wait *;
    }
     transitions 
    {
        can_help: goto can_help on #messageHasIntent("yes");
        bye: goto bye on #messageHasIntent("no");
    }
}

digression forgot_sth
{
    conditions {on #messageHasIntent("forgot_sth");}
    do
    {
        #sayText("That happens, don't worry. I'm sure we have whatever you need. What did you forget to bring?");
        wait *;
    }
    transitions
    {
        forgotten_thing: goto forgotten_thing on #messageHasData("forgotten_thing");
    }
}

node forgotten_thing
{
    do
    {
        var sentence = "Okay, we're about to bring  ";
        set $forgotten_thing = #messageGetData("forgotten_thing");
        for (var item in $forgotten_thing) {
            set sentence = sentence + (item.value ?? "and");
            }
        set sentence = sentence + " to you. Did I get that right?";
        #sayText(sentence); 
        wait *;
    }
     transitions 
    {
        confirm_forgotten: goto confirm_forgotten on #messageHasIntent("yes");
        repeat_forgotten: goto repeat_forgotten on #messageHasIntent("no");
    }
}

node confirm_forgotten
{ 
    do 
    { 
        #sayText("We're gonna bring it to to your room in 5 to 10 minutes. May I help with any other questions?");
        wait *;
    }
     transitions
    {
        can_help: goto can_help on #messageHasIntent("yes");
        repeat_forgotten: goto repeat_forgotten on #messageHasIntent("no");
    }
}

node repeat_forgotten
{
    do 
    {
        #sayText("Let's try this again. What was it that we can bring you?");
        wait *;
    }
    transitions 
    {
       forgotten_thing: goto forgotten_thing on #messageHasData("forgotten_thing");
    }
    onexit
    {
        forgotten_thing: do {
        set $forgotten_thing = #messageGetData("forgotten_thing");
       }
    }
}

digression dry_cleaning
{
    conditions {on #messageHasIntent("dry_cleaning");}
    do
    {
     #sayText("Absolutely, we'll pick your clothes up soon and send it to the dry cleaning service. We'll bring your clothes back to you in 1 day. Is there anything else I can help you with?");
     wait *;
    }
}

digression never_mind
{
    conditions {on #messageHasIntent("never_mind");}
    do
    {
        #sayText("That's totally fine. Is there something I can help you with?");
        wait *;
    }
}

digression hotel_restautant
{
    conditions {on #messageHasIntent("hotel_restautant");}
    do
    {
     #sayText("We do have a restaurant on the first floor. It's open from 7am to 11pm and we're looking forward to seeing you there. May I help with anything else?");
     wait *;
    }
}

digression vicinity
{
    conditions {on #messageHasIntent("vicinity");}
    do
    {
     #sayText("There are parks, cinemas, restauntants and an amusement park in the area. What interests you the most at this moment?");
     wait *;
    }
}

digression park
{
    conditions {on #messageHasIntent("park");}
    do
    {
        #sayText("We have two parks nearby: sunrise valley park and oak tree park, both are super beautiful and open twenty four seven. Both are located right outside the hotel within a two minute walking distance. Is there anything else I can tell you about?");
        wait *;
    }
}

digression cinemas
{
    conditions {on #messageHasIntent("cinemas");}
    do
    {
        #sayText("There’s ABA cinema that's located just 5 minutes away to the south of the hotel. It's open from 9 AM to 1 AM. Is there anything else I can tell you about?");
        wait *;
    }
}

digression restaurants
{
    conditions {on #messageHasIntent("restaurants");}
    do
    {
        #sayText("The 2 amazing restaurants around are Kimchi One restaurant, which is open from 9 AM to 9 PM and Bonjorno restaurant, open from 8 AM to 11 PM. Is there anything else I can help with?");
        wait *;
    }
}

digression amusement_park
{
    conditions {on #messageHasIntent("amusement_park");}
    do
    {
        #sayText("There's an amusement park which is within a 15 minute drive. You can take the free shuttle that's located right outside the hotel entrance to get there. But make sure to go there within its working hours, it closes at 4pm these days. Is there anything else I can help with?");
        wait *;
    }
}

digression check_out_q
{
    conditions {on #messageHasIntent("check_out_q");}
    do
    {
     #sayText("What would you like to know about your check out?");
     wait *;
    }
    transitions
    {
        check_out_diff_hour: goto check_out_diff_hour on #messageHasIntent("check_out_diff_hour");
        check_out_diff_day: goto check_out_diff_day on #messageHasIntent("check_out_diff_day");
    }
}

node check_out_diff_hour
{
    do
    {
        #sayText("What time would you like to check out?");
        wait *;
    }
    transitions 
    {
       new_checkout_hour: goto new_checkout_hour on #messageHasData("time");
    }
    onexit
    {
        new_checkout_hour: do 
        {
        set $new_time = #messageGetData("time")[0]?.value??"";
        }
    }
}

digression check_out_diff_hour
{
    conditions {on #messageHasIntent("check_out_diff_hour");}
    do
    {
     #sayText("What time would you like to check out?");
     wait *;
    }
    transitions 
    {
       new_checkout_hour: goto new_checkout_hour on #messageHasData("time");
    }
    onexit
    {
        new_checkout_hour: do 
        {
        set $new_time = #messageGetData("time")[0]?.value??"";
        }
    }
}

node new_checkout_hour
{ 
    do 
    { 
        #sayText("You got it. I just changed your checkout time to " + $new_time + ". Did I get that correctly?");
        wait *;
    }
    transitions
    {
        can_help: goto can_help on #messageHasIntent("yes");
        repeat_new_checkout_hour: goto repeat_new_checkout_hour on #messageHasIntent("no");
    }
}

node repeat_new_checkout_hour
{
    do 
    {
        #sayText("Let's do it one more time. What hour would you like to check out?");
        wait *;
    }
    transitions 
    {
       check_out_diff_hour: goto check_out_diff_hour on #messageHasData("time");
    }
    onexit
    {
        check_out_diff_hour: do {
        set $new_time = #messageGetData("time")[0]?.value??"";
       }
    }
}

node check_out_diff_day
{
    do
    {
        #sayText("What day would you like to check out?");
        wait *;
    }
    transitions 
    {
       new_checkout_day: goto new_checkout_day on #messageHasData("day_of_week");
    }
    onexit
    {
        new_checkout_day: do 
        {
        set $new_day = #messageGetData("day_of_week")[0]?.value??"";
        }
    }
}

digression check_out_diff_day
{
    conditions {on #messageHasIntent("check_out_diff_day");}
    do
    {
        #sayText("What day would you like to check out?");
        wait *;
    }
    transitions 
    {
       new_checkout_day: goto new_checkout_day on #messageHasData("day_of_week");
    }
    onexit
    {
        new_checkout_day: do 
        {
        set $new_day = #messageGetData("day_of_week")[0]?.value??"";
        }
    }
}

node new_checkout_day
{ 
    do 
    { 
        #sayText("Just changed your checkout day to " + $new_day + ". Is that right?");
        wait *;
    }
        transitions
    {
        can_help: goto can_help on #messageHasIntent("yes");
        repeat_new_checkout_day: goto repeat_new_checkout_day on #messageHasIntent("no");
    }
}

node repeat_new_checkout_day
{
    do 
    {
        #sayText("Let's do it one more time. What day would you like to check out?");
        wait *;
    }
    transitions 
    {
       new_checkout_day: goto check_out_diff_day on #messageHasData("day_of_week");
    }
    onexit
    {
        new_checkout_day: do {
        set $new_day = #messageGetData("day_of_week")[0]?.value??"";
       }
    }
}

node can_help
{
    do
    {
        #sayText("May I help you with anything else?");
        wait *;
    }
}

digression bye 
{
    conditions { on #messageHasIntent("bye"); }
    do 
    {
        #sayText("Thanks for staying with us! Have a great day. Bye!");
        #disconnect();
        exit;
    }
}

node bye
    {
        do 
    {
        #sayText("Thanks for staying with us! Have a great day. Bye!");
        #disconnect();
        exit;
    }
}

node no_dice_bye 
{
    do 
    {
        #sayText("Sorry I couldn't help you today. Have a great day. Bye!");
        #disconnect();
        exit;
    }
}



