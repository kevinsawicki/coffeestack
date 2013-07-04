(function() {
  var Test;

  module.exports = Test = (function() {
    function Test() {
      this.name = 'Test';
    }

    Test.prototype.getName = function() {
      return 'Test';
    };

    Test.prototype.fail = function() {
      throw new Error('this is an error');
    };

    Test.prototype.toString = function() {
      return this.getName();
    };

    return Test;

  })();

}).call(this);
