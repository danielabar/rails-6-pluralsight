<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Ruby on Rails 6: Getting Started](#ruby-on-rails-6-getting-started)
  - [Setting Up a Rails Application](#setting-up-a-rails-application)
    - [Creating Your First Rails App](#creating-your-first-rails-app)
      - [Bundler](#bundler)
    - [Adding Features with Scaffolds](#adding-features-with-scaffolds)
    - [Creating a Basic Static Page](#creating-a-basic-static-page)

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

def show
  # will render wiki/app/views/wiki_posts/example.html.erb
  render "example"
end
```

Now it renders the example view:

![wiki posts example view](doc-images/wiki-posts-example-view.png "wiki posts example view")

Left at 2:07 of Creating a Basic Static Page