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
### Gestion de la navigation
###----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----###
*/
(function() {
    class Page {
        constructor(url) {
            this.url = 'views/' + url;
        }

        load() {
            return fetch(this.url)
                .then(response => {
                    if (response.ok) {
                        return response.text();
                    } else {
                        return Promise.reject({
                            status: response.status,
                            message: response.statusText
                        })
                    }
                })
                .then(data => this.html = data)
                .catch(error => this.notifyLoadError(error));
        }

        show(el) {
            el.innerHTML = this.html;
        }

        notifyLoadError(error) {
            var html = [
                '<div class="notification is-danger">',
                    '<p class="title">Erreur</p>',
                    '<p class="subtitle">Il semble impossible de récupérer la vue: <b>' + this.url + '</b></p>',
                    '<p>Status: ' + error.status + '</p>',
                    '<p>Message: ' + error.message + '</p>',
                '</div>'
            ];
            this.html = html.join("\n");
        }
    }

    class Layout {
        constructor(...pages) {
            this.pages = pages;
        }

        load() {
            return Promise.all(this.pages.map(page => page.load()));
        }

        show(el) {
            for (let page of this.pages) {
                const div = document.createElement('div');
                page.show(div);
                el.appendChild(div);
            }
        }
    }

    class Router {
        constructor(routes, defaultPage, el) {
            this.routes = routes;
            this.defaultPage = defaultPage;
            this.el = el;
            window.onhashchange = this.hashChanged.bind(this);
        }

        async hashChanged() {
            if (window.location.hash.length > 0) {
                const pageName = window.location.hash.substr(1);
                this.show(pageName);
            } else if (this.routes[this.defaultPage]) {
                this.show(this.defaultPage);
            }
        }

        async show(pageName) {
            const page = this.routes[pageName];
            await page.load();
            this.el.innerHTML = '';
            page.show(this.el);
        }
    }

    const router = new Router(
        {
            services: new Page('services.html'),
            workers:  new Page( 'workers.html'),
        },
        'services',
        document.querySelector('main')
    );

    router.hashChanged();
})();

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
