/*
#######
##                                           _
##   ___ _______ _  ___ ___       ___ ___ __(_)
##  / _ `/ __/  ' \/ -_) _ \  _  / _ `/ // / /
##  \_,_/_/ /_/_/_/\__/_//_/ (_) \_, /\_,_/_/
##                              /___/
##
####### Ecosystème basé sur les microservices ##################### (c) 2018 losyme ####### @(°_°)@
*/

/*
###----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----###
### Une fois le document HTML complètement chargé
###----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----###
*/
(function() {
    function navbarBurgers() {
        var navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);
        if (navbarBurgers.length > 0) {
            navbarBurgers.forEach(function (el) {
                el.addEventListener('click', function () {
                    var target = document.getElementById(el.dataset.target);
                    el.classList.toggle(    'is-active');
                    target.classList.toggle('is-active');

                });
            });
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        navbarBurgers();
    });
})();

/*
####### END
*/
