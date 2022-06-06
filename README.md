<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Ruby on Rails 6: Getting Started](#ruby-on-rails-6-getting-started)
  - [Setting Up a Rails Application](#setting-up-a-rails-application)
    - [Creating Your First Rails App](#creating-your-first-rails-app)
      - [Bundler](#bundler)
    - [Adding Features with Scaffolds](#adding-features-with-scaffolds)
    - [Creating a Basic Static Page](#creating-a-basic-static-page)
      - [About Page](#about-page)
      - [Link to About Page from Index](#link-to-about-page-from-index)
  - [Populating Pages in Rails](#populating-pages-in-rails)
    - [Creating New Paths with Routes](#creating-new-paths-with-routes)
      - [Wiki Posts Model](#wiki-posts-model)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Ruby on Rails 6: Getting Started

My notes from Pluralsight [course](https://app.pluralsight.com/library/courses/getting-started-ruby-rails/table-of-contents).

## Setting Up a Rails Application

### Creating Your First Rails App

Create a Wiki in Rails. User can submit, edit, and delete posts.

Versions used in course, some outdated but stick to these for consistency:

* Ruby 2.5.0 -> too many problems, use 2.7.2 instead!
* Rails 6.1.4
* Node.js 12
* NPM 7

```bash
# Set node version instructor is using
touch .nvmrc
echo "12.18.1" > .nvmrc

# Node 12 ships with npm 6.x so explicitly install npm 7.x
npm install npm@7.24.2 -g

# Set slightly updated Ruby version from what instructor is using
rbenv install 2.7.2
rbenv local 2.7.2

# Install version of Rails CLI instructor is using
gem install rails -v 6.1.4
```

Instructor's [repo](https://github.com/XFactor-Consultants/Ruby-Getting-Started)

**MVC**

Pattern of organizing a web application's architecture:

![mvc](doc-images/mvc.png "mvc")

Model: Resources user of web application would like to access

Controller: Associated with model, handle all back end functionality

View: Controller serves views to show Model to user in a user-friendly page

Business logic is grouped by resources and separated by its purpose. When looking at an MVC code base to understand what it does, look at:

* Views to see how resource is rendered to user
* Models to see how data is stored
* Controller to see how business logic wrt resource works

Rails is more opinionated than other MVC frameworks.

Scaffold a new app:

```bash
rails new wiki
```

#### Bundler

Part of `rails new...` scaffold is to run bundler.

* Not part of Rails or Ruby
* Package manager that handles gems (similar to npm, yarn, pip, etc.)
* Gems are standard ruby libraries
* Ruby itself doesn't have a library system, but allows you to import other files
* Bundler and gems make importing easier and consistent
* Bundler comes with Rails by default
* When Bundler started, gems listed in `Gemfile` are automatically installed
* No need to distribute licensed Gems with a project
* Sometimes gems require other gems - dependency tree, bundler installs all of these

When `rails new project`, also runs webpacker (will discuss more later), it's for front end development.

webpacker uses `yarn`:

```
run yarn add @rails/webpacker@5.4.0...
```

Yarn is JavaScript package manager, similar to npm, used to install all the front end JavaScript dependencies.

Start server, `s` is short for `serve`.

```
bin/rails s
```

This tells the OS to execute the Rails binary that was installed in this project by bundler.

This starts the development server. Has *hot reloading* - can make changes to front or back end, refresh browser and see changes - no need to reboot server.

Rails default hello world page available at `http://localhost:3000`

### Adding Features with Scaffolds

Note the views files, eg: `wiki/app/views/layouts/application.html.erb`

```ruby
<!DOCTYPE html>
<html>
  <head>
    <title>Wiki</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <%= yield %>
  </body>
</html>
```

`.html.erb` extension is an html template file with support for Ruby logic.

erb: Embedded Ruby

Following symbol means what follows is Ruby syntax rather than html:

`<%= some_expression %>`

This doesn't get sent to browser directly. Rather, a compiler library `haml` takes the erb template and checks for any Ruby tags, then evaluates and executes that code. Whatever is returned from that gets written to the final html file sent to browser/client.

` <%= yield %>` tells Ruby that to put into the page, whatever the current controller has. This supports template inheritance and wrapping views inside other views.

If we make a change to the application template at this point, eg: replace yield with some h1 text, refresh browser, nothing changes!

```ruby
<body>
  <h1>Hello Rails Course</h1>
</body>
```

This is because we have not yet defined a controller for the home route `/`.

Let's create a controller, and view to see effect of changing application template.

The Rails CLI provides many generators to create just about any Rails file.

This command will create a Welcome controller with an `index` action. We don't need a model at this time. A controller action is a function that represents doing something to a resource. We only want the index page so let's call the action `index`:

```
bin/rails generate controller Welcome index
```

Output:

```
create  app/controllers/welcome_controller.rb
 route  get 'welcome/index'
invoke  erb
create    app/views/welcome
create    app/views/welcome/index.html.erb
invoke  test_unit
create    test/controllers/welcome_controller_test.rb
invoke  helper
create    app/helpers/welcome_helper.rb
invoke    test_unit
invoke  assets
invoke    scss
create      app/assets/stylesheets/welcome.scss
```

Here's the controller with action method generated by the scaffold:

```ruby
# wiki/app/controllers/welcome_controller.rb
class WelcomeController < ApplicationController
  def index
  end
end
```

Here's the associated view that goes with this controller action. Note that since controller is `Welcome` and action is `index`, the view is generated at `views/welcome/index.html.erb`:

```html
<!-- wiki/app/views/welcome/index.html.erb -->
<h1>Welcome#index</h1>
<p>Find me in app/views/welcome/index.html.erb</p>
```

Also got a generated view helper, unit test, and sass. Don't need for now, will come back to this later.

The generator also added an entry to the routes file:

```ruby
# wiki/config/routes.rb
Rails.application.routes.draw do
  get 'welcome/index'
end
```

The method `get 'welcome/index'` tells Rails there's a GET endpoint at controller `welcome` and action `index`. Behind the scenes, Rails maps routes to controller actions and views.

Let's add the `root` method, which takes a different syntax in the form of `controller#action`:

```ruby
# wiki/config/routes.rb
Rails.application.routes.draw do
  get 'welcome/index'
  root 'welcome#index'
end
```

Remember to put `yield` back in the main application layout:

```ruby
<!DOCTYPE html>
<html>
  <head>
    <title>Wiki</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <%= yield %>
  </body>
</html>
```

Now, run server and navigate to `http://localhost:3000`, and it will render the welcome/index view:

![welcome index view](doc-images/welcome-index-view.png "welcome index view")

Notice we didn't have to explicitly render the template, there's no code in the controller action. Rails does all this by convention.

So far we have route, controller, and view.

Now need to add data model. Will use `scaffold` command to [generate](https://guides.rubyonrails.org/command_line.html#bin-rails-generate) everything needed:

```
bin/rails generate scaffold WikiPost
```

Output:

```
invoke  active_record
create    db/migrate/20220604121631_create_wiki_posts.rb
create    app/models/wiki_post.rb
invoke    test_unit
create      test/models/wiki_post_test.rb
create      test/fixtures/wiki_posts.yml
invoke  resource_route
 route    resources :wiki_posts
invoke  scaffold_controller
create    app/controllers/wiki_posts_controller.rb
invoke    erb
create      app/views/wiki_posts
create      app/views/wiki_posts/index.html.erb
create      app/views/wiki_posts/edit.html.erb
create      app/views/wiki_posts/show.html.erb
create      app/views/wiki_posts/new.html.erb
create      app/views/wiki_posts/_form.html.erb
invoke    resource_route
invoke    test_unit
create      test/controllers/wiki_posts_controller_test.rb
create      test/system/wiki_posts_test.rb
invoke    helper
create      app/helpers/wiki_posts_helper.rb
invoke      test_unit
invoke    jbuilder
create      app/views/wiki_posts/index.json.jbuilder
create      app/views/wiki_posts/show.json.jbuilder
create      app/views/wiki_posts/_wiki_post.json.jbuilder
invoke  assets
invoke    scss
create      app/assets/stylesheets/wiki_posts.scss
invoke  scss
create    app/assets/stylesheets/scaffolds.scss
```

This generated a database migration, when run, will generate a database table to contain our wiki posts. Right now, this table only has timestamps columns to persist when record was created and last updated:

```ruby
# wiki/db/migrate/20220604121631_create_wiki_posts.rb
class CreateWikiPosts < ActiveRecord::Migration[6.1]
  def change
    create_table :wiki_posts do |t|

      t.timestamps
    end
  end
end
```

Generated a model to define the data class:

```ruby
# wiki/app/models/wiki_post.rb
class WikiPost < ApplicationRecord
end
```

Generated a controller with all action methods needed to work with the model:

```ruby
# wiki/app/controllers/wiki_posts_controller.rb
class WikiPostsController < ApplicationController
  before_action :set_wiki_post, only: %i[ show edit update destroy ]

  # GET /wiki_posts or /wiki_posts.json
  def index
    @wiki_posts = WikiPost.all
  end

  # GET /wiki_posts/1 or /wiki_posts/1.json
  def show
  end

  # GET /wiki_posts/new
  def new
    @wiki_post = WikiPost.new
  end

  # GET /wiki_posts/1/edit
  def edit
  end

  # POST /wiki_posts or /wiki_posts.json
  def create
    @wiki_post = WikiPost.new(wiki_post_params)

    respond_to do |format|
      if @wiki_post.save
        format.html { redirect_to wiki_post_url(@wiki_post), notice: "Wiki post was successfully created." }
        format.json { render :show, status: :created, location: @wiki_post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @wiki_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wiki_posts/1 or /wiki_posts/1.json
  def update
    respond_to do |format|
      if @wiki_post.update(wiki_post_params)
        format.html { redirect_to wiki_post_url(@wiki_post), notice: "Wiki post was successfully updated." }
        format.json { render :show, status: :ok, location: @wiki_post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @wiki_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wiki_posts/1 or /wiki_posts/1.json
  def destroy
    @wiki_post.destroy

    respond_to do |format|
      format.html { redirect_to wiki_posts_url, notice: "Wiki post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wiki_post
      @wiki_post = WikiPost.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def wiki_post_params
      params.fetch(:wiki_post, {})
    end
end
```

Controller has actions for:
* `show`: view a single instance of WikiPost model
* `index`: view all instances of WikiPost models
* `new`: create a new instance of WikiPost model
* `edit`: edit an existing instance of WikiPost model

Controller also supports json endpoints for API access.

The generator also added a `resources` method to the routes file to expose all the standard HTTP endpoints to manipulate the WikiPosts data model:

```ruby
# wiki/config/routes.rb
Rails.application.routes.draw do
  resources :wiki_posts
  get 'welcome/index'
  root 'welcome#index'
end
```

Trying to navigate to any of the endpoints, for example `http://localhost:3000/wiki_posts.json` results in an `ActiveRecord::PendingMigrationError`:

![pending migration error](doc-images/pending-migration-error.png "pending migration error")

This is because the `scaffold` command we ran earlier generated a database migration for the WikiPosts model, but it hasn't been run yet.

Run db migration, this will add new table to persist WikiPosts data model to schema:

```
bin/rails db:migrate RAILS_ENV=development
```

Output:

```
== 20220604121631 CreateWikiPosts: migrating ==================================
-- create_table(:wiki_posts)
   -> 0.0025s
== 20220604121631 CreateWikiPosts: migrated (0.0026s) =========================
```

Restart server and navigate to `http://localhost:3000/wiki_posts.json` (get all wiki posts), and this time, it returns an empty json array (no more errors):

```json
[ ]
```

### Creating a Basic Static Page

Let's create a first example wiki post.

The scaffold generated some content in the wiki posts index view for us, which lists every existing data record, and a link to create a new one:

```ruby
<p id="notice"><%= notice %></p>

<h1>Wiki Posts</h1>

<table>
  <thead>
    <tr>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @wiki_posts.each do |wiki_post| %>
      <tr>
        <td><%= link_to 'Show', wiki_post %></td>
        <td><%= link_to 'Edit', edit_wiki_post_path(wiki_post) %></td>
        <td><%= link_to 'Destroy', wiki_post, method: :delete, data: { confirm: 'Are you sure?' } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to 'New Wiki Post', new_wiki_post_path %>
```

Let's delete the tabular display:

```ruby
# wiki/app/views/wiki_posts/index.html.erb
<p id="notice"><%= notice %></p>

<h1>Wiki Posts</h1>

<%= link_to 'New Wiki Post', new_wiki_post_path %>
```

This page will need an example wiki post, create this view as simple static html for now:

```html
<!-- wiki/app/views/wiki_posts/example.html.erb -->
<h1>Wiki Page Title</h1>

<p> Wiki Page Body</p>

<div>
  <span>Wiki Page Author</span>
  <span>Wiki Page Creation Date</span>
</div>
```

Now try navigating to display the example view at `http://localhost:3000/wiki_posts/example`, but get `ActiveRecord::RecordNotFound` error:

![active record not found error](doc-images/active-record-not-found-error.png "active record not found error")

This is because a url like `GET /resource/:id` is mapped to the `show` method in the welcome controller, which will first attempt to find the WikiPost by the given `id` parameter in the url:

```ruby
# wiki/app/controllers/wiki_posts_controller.rb
class WikiPostsController < ApplicationController
  before_action :set_wiki_post, only: %i[ show edit update destroy ]

  # GET /wiki_posts/1 or /wiki_posts/1.json
  def show
  end

  # other methods...

  private
    def set_wiki_post
      @wiki_post = WikiPost.find(params[:id])
    end
end
```

So given a url like `wiki_posts/example`, it's trying to find a record in the wiki_posts table whose id is `example`, and there is no such thing.

Fix this: Change `show` method to render the example view just created. Also need to remove `show` from `before_action` list to stop Rails from trying to look up a specific record by id:

```ruby
# wiki/app/controllers/wiki_posts_controller.rb
before_action :set_wiki_post, only: %i[ edit update destroy ]

# GET /wiki_posts/1 or /wiki_posts/1.json
def show
  # will render wiki/app/views/wiki_posts/example.html.erb
  render "example"
end
```

Now it renders the example view:

![wiki posts example view](doc-images/wiki-posts-example-view.png "wiki posts example view")

Change endpoint from `http://localhost:3000/wiki_posts/example` to `http://localhost:3000/wiki_posts/1` -> still renders same page. Because we overrode `show` method in controller to always render the same static page.

#### About Page

Adding another static page `welcome/about`.

Start by adding `about` method in the Welcome controller. Note that no method implementation needed, just the method name:

```ruby
# wiki/app/controllers/welcome_controller.rb
class WelcomeController < ApplicationController
  def index
  end

  def about
  end
end
```

Then create view which Rails will map controller action to by default:

```htm
<!-- wiki/app/views/welcome/about.html.erb -->
<h1>Wiki Information</h1>
```

Add a route for the about view:

```ruby
# wiki/config/routes.rb
Rails.application.routes.draw do
  resources :wiki_posts
  get 'welcome/index'
  get 'welcome/about'
  root 'welcome#index'
end
```

Navigate in browser to `http://localhost:3000/welcome/about`:

![about page](doc-images/about-page.png "about page")

Now we want about page to be available at `/about` rather than `/welcome/about`. Use *redirect* for this with `to` in router:

```ruby
# wiki/config/routes.rb
Rails.application.routes.draw do
  resources :wiki_posts
  get 'welcome/index'
  get 'welcome/about'
  get '/about', to: redirect('/welcome/about')
  root 'welcome#index'
end
```

Now can navigate to `http://localhost:3000/about` and browser redirects to `http://localhost:3000/welcome/about` to display the about page.

#### Link to About Page from Index

Edit welcome index view to link to about page. No need to explicitly type out an anchor tag. Use some Ruby code that will generate it with the `link_to` method. Specify link text and path for this method

```erb
<!-- wiki/app/views/welcome/index.html.erb -->
<h1>Wiki</h1>
<p>Posts will go here</p>

<%= link_to "About", "/about" %>
```

Navigate to root to see this `http://localhost:3000`:

![root with about link](doc-images/root-with-about-link.png "root with about link")

BUT notice the use of a hard-coded path passed to link_to method "/about". Any future change to paths would break this link. Better to use a variable `welcome_about_path`.

We haven't defined this variable - Rails "magic". Works because there's a "welcome" controller with an "about" action, so Rails exposes a variable `welcome_about_path` to link to this.

```erb
<!-- wiki/app/views/welcome/index.html.erb -->
<h1>Wiki</h1>
<p>Posts will go here</p>

<%= link_to "About", welcome_about_path %>
```

## Populating Pages in Rails

### Creating New Paths with Routes

Back to `wiki/app/controllers/wiki_posts_controller.rb`. Earlier we edited `show` method to render the static example page:

```ruby
# wiki/app/controllers/wiki_posts_controller.rb

def show
  render "example"
end
```

But that's not what a typical Rails app expects. `show` action should be used to show an instance of a model. Remove example code from `show` action and move to new action `example`:

```ruby
# wiki/app/controllers/wiki_posts_controller.rb
def show
end

def example
  render "example"
end
```

Now navigating to `http://localhost:3000/wiki_posts/example` get `ActionController::UrlGenerationError in WikiPosts#show`:

![url generation error](doc-images/urll-generation-error.png "url generation error")

The problem is `/wiki_posts/example` is trying to load the `/show/:id` view because that's one of the routes exposed by `resources :wiki_posts` in the router file `wiki/config/routes.rb`.

To resolve this, need to define a route to the `example` action and point it to our controller. Add this line to router:

```ruby
# wiki/config/routes.rb
Rails.application.routes.draw do
  # expose example method in wiki_posts_controller as a route
  get 'wiki_posts/example'

  resources :wiki_posts
  get 'welcome/index'
  get 'welcome/about'
  get '/about', to: redirect('/welcome/about')
  root 'welcome#index'
end
```

With this fix, navigate to `http://localhost:3000/wiki_posts/example` and now example page renders.

How did Rails know what to do given this line in router file: `get 'wiki_posts/example'`?

It infers the `wiki_posts_controller` from `wiki_posts` in the router line. And it didn't attempt to load `/show/:id` route because it saw the specific line `get wiki_posts/example` in router *before* the `resources :wiki_posts` line.

In the case of potential multiple matching routes, Rails always maps to first route matched.

Another convention, the explicit render of example can be removed from the action, and Rails will still render the example view - it matches the view name to the controller action name:

```ruby
# wiki/app/controllers/wiki_posts_controller.rb
def example
end
```

#### Wiki Posts Model

Model is bare-bones at the moment with only timestamps columns. Use generator to add a migration to define further attributes for the model.

`g` is short for `generate`, which does something similar to `scaffold` but narrower scope. Naming convention for migrations is "add column to model". List of field names:datatype is last argument:

```
bin/rails g migration add_title_to_wiki_posts title:string
```

Output:

```
invoke  active_record
create    db/migrate/20220606103844_add_title_to_wiki_posts.rb
```

Rails writes the code to add the "title" column to the wiki_posts table in the migration:

```ruby
# wiki/db/migrate/20220606103844_add_title_to_wiki_posts.rb
class AddTitleToWikiPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :wiki_posts, :title, :string
  end
end
```

Run the migration:

```
bin/rails db:migrate
```

Output:

```
== 20220606103844 AddTitleToWikiPosts: migrating ==============================
-- add_column(:wiki_posts, :title, :string)
   -> 0.0049s
== 20220606103844 AddTitleToWikiPosts: migrated (0.0050s) =====================
```

Use Rails console to make an instance of this model:

```
bin/rails c
```

```ruby
irb(main):001:0> WikiPost.new :title => "First Post"
   (1.1ms)  SELECT sqlite_version(*)
=> #<WikiPost id: nil, created_at: nil, updated_at: nil, title: "First Post">
```

Try to load this post in the browser view: `http://localhost/wiki_posts/1`. But get same error as before: `ActionController::UrlGenerationError in WikiPosts#show`.

Problem is `WikiPost.new...` created an instance of the model, but doesn't save to database.

Rails Active Record ORM (Object Relational Mapping) supports defining instances of classes (models in this case) in Ruby code, which represent data structure in db. This avoids having to explicitly connect to db in code and write sql queries.

But need to remember to *save* model instance to db, back in Rails console, use `create` method instead of `new` on WikiPost model class:

```ruby
irb(main):001:0> WikiPost.create(:title => "First Post")
TRANSACTION (1.0ms)  begin transaction
  WikiPost Create (2.8ms)  INSERT INTO "wiki_posts" ("created_at", "updated_at", "title") VALUES (?, ?, ?)  [["created_at", "2022-06-06 10:59:18.294132"], ["updated_at", "2022-06-06 10:59:18.294132"], ["title", "First Post"]]
  TRANSACTION (1.2ms)  commit transaction
=> #<WikiPost id: 1, created_at: "2022-06-06 10:59:18.294132000 +0000", updated_at: "2022-06-06 10:59:18.294132000 +0000", title: "First Post">
```

Also modify controller to put back temp change we made earlier to not have `show` method included in list of actions that would load a model instance by given `:id` in the route:

```ruby
# wiki/app/controllers/wiki_posts_controller.rb
before_action :set_wiki_post, only: %i[ edit update destroy show ]
```

Now rendering page `http://localhost:3000/wiki_posts/1` works:

![wiki posts 1 renders](doc-images/wiki-posts-1-renders.png "wiki posts 1 renders")

Left at 8:03 of Creating New Paths with Routes