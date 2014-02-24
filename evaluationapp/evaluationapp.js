Votes = new Meteor.Collection('votes'); // create a collection

if (Meteor.isClient) {

  Template.hello.events({
    'click button#submit' : function () {

      // get the values of the checked button when pressed submit
      var value1 = $('input[name="optionsRadios1"]:checked').attr('value');
      var value2 = $('input[name="optionsRadios2"]:checked').attr('value');
      var value3 = $('input[name="optionsRadios3"]:checked').attr('value');
      var value4 = $('input[name="optionsRadios4"]:checked').attr('value');
      var value5 = $('input[name="optionsRadios5"]:checked').attr('value');
      var value6 = $('input[name="optionsRadios6"]:checked').attr('value');
      var value7 = $('input[name="optionsRadios7"]:checked').attr('value');

      // if any of the radioboxes not checked raise an error
      if ( value1 && value2 && value3 && value4 && value5 && value6 && value7 ) {
        Meteor.call('vote',
          value1, value2, value3, value4, value5, value6, value7
        ); // call vote function
        $( 'input:checked' ).prop('checked',false); // clear the inputs
        $('.alert-success').show().
          delay(2000).hide(2000); // show success message
      } else {
        $('.alert-danger').show().delay(2000).hide(2000);  // show warning
      }
    }
  });
}

if (Meteor.isServer){
  // vote function
  Meteor.methods({
    vote: function (value1, value2, value3, value4, value5, value6, value7) {
      Votes.upsert({'name': 'out1'}, {$push: {'votes': value1}});
      Votes.upsert({'name': 'out2'}, {$push: {'votes': value2}});
      Votes.upsert({'name': 'out3'}, {$push: {'votes': value3}});
      Votes.upsert({'name': 'out4'}, {$push: {'votes': value4}});
      Votes.upsert({'name': 'out5'}, {$push: {'votes': value5}});
      Votes.upsert({'name': 'out6'}, {$push: {'votes': value6}});
      Votes.upsert({'name': 'out7'}, {$push: {'votes': value7}});
    }
  });
}
console.log("lol");
