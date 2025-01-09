create function default_page(request http_request) returns setof http_outcome as
$$
begin
    return query (with
                      stats as (select * from pg_catalog.pg_stat_database where datname = current_database())
                  select *
                  from
                      omni_httpd.http_response(headers => array [omni_http.http_header('content-type', 'text/html')],
                                               body => $html$
       <!DOCTYPE html>
       <html>
         <head>
           <title>Omnigres</title>
           <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css">
           <meta name="viewport" content="width=device-width, initial-scale=1">
         </head>
         <body class="container">
         <section class="section">
           <div class="container">
             <h1 class="title">Omnigres</h1>

             <div class="tile is-ancestor">
                <div class="tile is-parent is-8">
                 <article class="tile is-child notification is-primary">
                   <div class="content">
                     <p class="title">Welcome!</p>
                     <p class="subtitle">What's next?</p>
                     <div class="content">
                     <p>You can update the query in the <code>omni_httpd.handlers</code> table to change this default page.</p>

                     <p><a href="https://docs.omnigres.org">Documentation</a></p>
                     </div>
                   </div>
                 </article>
               </div>
               <div class="tile is-vertical">
                 <div class="tile">
                   <div class="tile is-parent is-vertical">
                     <article class="tile is-child notification is-grey-lighter">
                       <p class="title">Database</p>
                       <p class="subtitle"><strong>$html$ || current_database() || $html$</strong></p>
                       <p> <strong>Backends</strong>: $html$ || (select numbackends from stats) || $html$ </p>
                       <p> <strong>Transactions committed</strong>: $html$ || (select xact_commit from stats) || $html$ </p>
                     </article>
                   </div>
                 </div>
               </div>
             </div>

             <div class="tile is-ancestor">
               <div class="tile">
                 <div class="tile is-parent is-vertical">
                   <article class="tile is-child notification is-grey-lighter">
                     <p class="title">Listeners</p>
                     <p>$html$ || (select json_agg(row_to_json(cl))::text from omni_httpd.cluster_listeners() cl) || $html$ </p>
                   </article>
                 </div>
               </div>
             </div>

             <p class="is-size-7">
               Running on <strong> $html$ || version() || $html$ </strong>
             </p>
           </div>
         </section>
         </body>
       </html>
       $html$));
end;
$$ language plpgsql;
